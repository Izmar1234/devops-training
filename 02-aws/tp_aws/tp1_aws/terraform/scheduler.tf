data "archive_file" "scheduler_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/scheduler.py"
  output_path = "${path.module}/lambda/scheduler.zip"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    sid     = "LambdaAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_scheduler" {
  provider = aws.without_default_tags

  name = "${local.name_prefix}_role_lambda_scheduler"

  assume_role_policy = (
    data.aws_iam_policy_document.lambda_assume_role.json
  )
}

resource "aws_cloudwatch_log_group" "lambda_scheduler" {
  name = "/aws/lambda/${local.name_prefix}_lambda_scheduler"

  retention_in_days = 14

  tags = {
    Name = "${local.name_prefix}_logs_lambda_scheduler"
  }
}

data "aws_iam_policy_document" "lambda_scheduler" {
  statement {
    sid       = "DescribeInstances"
    effect    = "Allow"
    actions   = ["ec2:DescribeInstances"]
    resources = ["*"]
  }

  statement {
    sid    = "StartStopTaggedInstances"
    effect = "Allow"

    actions = [
      "ec2:StartInstances",
      "ec2:StopInstances"
    ]

    resources = [
      "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:instance/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Owner"
      values   = ["${var.last_name}_${var.first_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Schedule"
      values   = [local.schedule_tag_value]
    }
  }

  statement {
    sid    = "WriteLambdaLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.lambda_scheduler.arn}:*"
    ]
  }
}

resource "aws_iam_policy" "lambda_scheduler" {
  provider = aws.without_default_tags

  name        = "${local.name_prefix}_policy_lambda_scheduler"
  description = "Permissions minimales pour demarrer et arreter les EC2 du TP"

  policy = data.aws_iam_policy_document.lambda_scheduler.json
}

resource "aws_iam_role_policy_attachment" "lambda_scheduler" {
  provider = aws.without_default_tags

  role       = aws_iam_role.lambda_scheduler.name
  policy_arn = aws_iam_policy.lambda_scheduler.arn
}

resource "aws_lambda_function" "scheduler" {
  function_name = "${local.name_prefix}_lambda_scheduler"

  description = "Démarre et arrête les EC2 du TP selon leurs tags"

  role    = aws_iam_role.lambda_scheduler.arn
  runtime = "python3.12"
  handler = "scheduler.lambda_handler"

  filename = data.archive_file.scheduler_lambda.output_path

  source_code_hash = (
    data.archive_file.scheduler_lambda.output_base64sha256
  )

  memory_size = 128
  timeout     = 30

  environment {
    variables = {
      OWNER_TAG    = "${var.last_name}_${var.first_name}"
      SCHEDULE_TAG = local.schedule_tag_value
    }
  }

  tags = {
    Name = "${local.name_prefix}_lambda_scheduler"
    Role = "ec2-scheduler"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_scheduler,
    aws_cloudwatch_log_group.lambda_scheduler
  ]
}

data "aws_iam_policy_document" "eventbridge_assume_role" {
  statement {
    sid     = "EventBridgeSchedulerAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eventbridge_scheduler" {
  provider = aws.without_default_tags

  name = "${local.name_prefix}_role_eventbridge_scheduler"

  assume_role_policy = (
    data.aws_iam_policy_document.eventbridge_assume_role.json
  )
}

data "aws_iam_policy_document" "eventbridge_invoke_lambda" {
  statement {
    sid    = "InvokeSchedulerLambda"
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction"
    ]

    resources = [
      aws_lambda_function.scheduler.arn
    ]
  }
}

resource "aws_iam_policy" "eventbridge_invoke_lambda" {
  provider = aws.without_default_tags

  name        = "${local.name_prefix}_policy_eventbridge_scheduler"
  description = "Autorise EventBridge Scheduler a invoquer uniquement la Lambda du TP"

  policy = (
    data.aws_iam_policy_document.eventbridge_invoke_lambda.json
  )
}

resource "aws_iam_role_policy_attachment" "eventbridge_invoke_lambda" {
  provider = aws.without_default_tags

  role       = aws_iam_role.eventbridge_scheduler.name
  policy_arn = aws_iam_policy.eventbridge_invoke_lambda.arn
}

resource "aws_scheduler_schedule" "start" {
  name = "${local.name_prefix}_schedule_start"

  description = "Démarre les EC2 du TP à 09h00, heure de Paris"

  schedule_expression          = "cron(0 9 * * ? *)"
  schedule_expression_timezone = "Europe/Paris"
  state                        = "ENABLED"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.scheduler.arn
    role_arn = aws_iam_role.eventbridge_scheduler.arn

    input = jsonencode({
      action = "start"
    })

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 2
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.eventbridge_invoke_lambda
  ]
}

resource "aws_scheduler_schedule" "stop" {
  name = "${local.name_prefix}_schedule_stop"

  description = "Arrête les EC2 du TP à 19h00, heure de Paris"

  schedule_expression          = "cron(0 19 * * ? *)"
  schedule_expression_timezone = "Europe/Paris"
  state                        = "ENABLED"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.scheduler.arn
    role_arn = aws_iam_role.eventbridge_scheduler.arn

    input = jsonencode({
      action = "stop"
    })

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 2
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.eventbridge_invoke_lambda
  ]
}