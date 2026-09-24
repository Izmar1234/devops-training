# ============================================================
# RÔLE D'EXÉCUTION LAMBDA
# ============================================================

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

resource "aws_iam_role" "scheduler_lambda" {
  provider = aws.without_default_tags

  name = "${var.name_prefix}_role_lambda_scheduler"

  assume_role_policy = (
    data.aws_iam_policy_document.lambda_assume_role.json
  )
}


# ============================================================
# GROUPE CLOUDWATCH LOGS
# ============================================================

resource "aws_cloudwatch_log_group" "scheduler" {
  name = "/aws/lambda/${var.name_prefix}_lambda_scheduler"

  retention_in_days = 14

  tags = {
    Name = "${var.name_prefix}_logs_lambda_scheduler"
    Role = "lambda-scheduler-logs"
  }
}


# ============================================================
# AUTORISATIONS DE LA LAMBDA
# ============================================================

data "aws_iam_policy_document" "lambda_scheduler" {
  statement {
    sid    = "DescribeTargetInstances"
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "StartStopOnlyTerraformInstances"
    effect = "Allow"

    actions = [
      "ec2:StartInstances",
      "ec2:StopInstances"
    ]

    resources = [
      var.docker_instance_arn,
      var.nodejs_instance_arn
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Owner"
      values   = [var.owner]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Schedule"
      values   = ["iac-office-hours"]
    }
  }

  statement {
    sid    = "WriteSchedulerLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.scheduler.arn}:*"
    ]
  }
}

resource "aws_iam_policy" "lambda_scheduler" {
  provider = aws.without_default_tags

  name        = "${var.name_prefix}_policy_lambda_scheduler"
  description = "Permissions EC2 et CloudWatch Logs pour la Lambda du TP"

  policy = data.aws_iam_policy_document.lambda_scheduler.json
}

resource "aws_iam_role_policy_attachment" "lambda_scheduler" {
  role       = aws_iam_role.scheduler_lambda.name
  policy_arn = aws_iam_policy.lambda_scheduler.arn
}
