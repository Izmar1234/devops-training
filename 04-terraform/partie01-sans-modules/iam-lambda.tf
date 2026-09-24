# ============================================================
# POLITIQUE DE CONFIANCE DU RÔLE LAMBDA
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


# ============================================================
# RÔLE D'EXÉCUTION DE LA LAMBDA
# ============================================================

resource "aws_iam_role" "scheduler_lambda" {
  provider = aws.without_default_tags

  name = "${local.name_prefix}_role_lambda_scheduler"

  assume_role_policy = (
    data.aws_iam_policy_document.lambda_assume_role.json
  )
}


# ============================================================
# GROUPE CLOUDWATCH LOGS DE LA LAMBDA
# ============================================================

resource "aws_cloudwatch_log_group" "scheduler" {
  name = "/aws/lambda/${local.name_prefix}_lambda_scheduler"

  retention_in_days = 14

  tags = {
    Name = "${local.name_prefix}_logs_lambda_scheduler"
    Role = "lambda-scheduler-logs"
  }
}


# ============================================================
# DOCUMENT DE POLITIQUE DE LA LAMBDA
# ============================================================

data "aws_iam_policy_document" "lambda_scheduler" {
  # Lambda doit lire l'état actuel des instances.
  statement {
    sid    = "DescribeTargetInstances"
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances"
    ]

    resources = ["*"]
  }


  # Lambda peut démarrer et arrêter uniquement les deux EC2
  # créées par cette configuration Terraform.
  statement {
    sid    = "StartStopOnlyTerraformInstances"
    effect = "Allow"

    actions = [
      "ec2:StartInstances",
      "ec2:StopInstances"
    ]

    resources = [
      aws_instance.docker.arn,
      aws_instance.nodejs.arn
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Owner"
      values   = [local.owner]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Schedule"
      values   = ["iac-office-hours"]
    }
  }


  # Lambda peut écrire uniquement dans son groupe CloudWatch.
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


# ============================================================
# POLITIQUE IAM GÉRÉE
# ============================================================

resource "aws_iam_policy" "lambda_scheduler" {
  provider = aws.without_default_tags

  name        = "${local.name_prefix}_policy_lambda_scheduler"
  description = "Permissions EC2 et CloudWatch Logs pour la Lambda du TP"

  policy = data.aws_iam_policy_document.lambda_scheduler.json
}


# ============================================================
# ASSOCIATION DE LA POLITIQUE AU RÔLE
# ============================================================

resource "aws_iam_role_policy_attachment" "lambda_scheduler" {
  role       = aws_iam_role.scheduler_lambda.name
  policy_arn = aws_iam_policy.lambda_scheduler.arn
}
