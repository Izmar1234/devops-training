# ============================================================
# POLITIQUE DE CONFIANCE EVENTBRIDGE SCHEDULER
# ============================================================

data "aws_iam_policy_document" "scheduler_assume_role" {
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


# ============================================================
# RÔLE D'EXÉCUTION EVENTBRIDGE SCHEDULER
# ============================================================

resource "aws_iam_role" "eventbridge_scheduler" {
  provider = aws.without_default_tags

  name = "${local.name_prefix}_role_eventbridge_scheduler"

  assume_role_policy = (
    data.aws_iam_policy_document.scheduler_assume_role.json
  )
}


# ============================================================
# AUTORISATION D'INVOQUER UNIQUEMENT NOTRE LAMBDA
# ============================================================

data "aws_iam_policy_document" "eventbridge_invoke_lambda" {
  statement {
    sid    = "InvokeOnlySchedulerLambda"
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

  name = (
    "${local.name_prefix}_policy_eventbridge_scheduler"
  )

  description = (
    "Autorise EventBridge Scheduler à invoquer la Lambda du TP"
  )

  policy = (
    data.aws_iam_policy_document.eventbridge_invoke_lambda.json
  )
}


resource "aws_iam_role_policy_attachment" "eventbridge_invoke_lambda" {
  role = aws_iam_role.eventbridge_scheduler.name

  policy_arn = (
    aws_iam_policy.eventbridge_invoke_lambda.arn
  )
}


# ============================================================
# DÉMARRAGE QUOTIDIEN À 09 H, HEURE DE PARIS
# ============================================================

resource "aws_scheduler_schedule" "start" {
  name = "${local.name_prefix}_schedule_start"

  description = (
    "Démarre les deux EC2 du TP à 09h00, heure de Paris"
  )

  schedule_expression = "cron(0 9 * * ? *)"

  schedule_expression_timezone = "Europe/Paris"

  state = "ENABLED"

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


# ============================================================
# ARRÊT QUOTIDIEN À 19 H, HEURE DE PARIS
# ============================================================

resource "aws_scheduler_schedule" "stop" {
  name = "${local.name_prefix}_schedule_stop"

  description = (
    "Arrête les deux EC2 du TP à 19h00, heure de Paris"
  )

  schedule_expression = "cron(0 19 * * ? *)"

  schedule_expression_timezone = "Europe/Paris"

  state = "ENABLED"

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
