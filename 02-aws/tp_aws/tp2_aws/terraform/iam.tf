# ============================================================
# IAM ET CLOUDWATCH LOGS POUR LA FONCTION LAMBDA
# ============================================================


# ------------------------------------------------------------
# 1. Politique de confiance du rôle Lambda
# ------------------------------------------------------------
# Cette politique autorise le service AWS Lambda à utiliser
# le rôle IAM créé plus bas.
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


# ------------------------------------------------------------
# 2. Rôle IAM utilisé par la fonction Lambda
# ------------------------------------------------------------
# Le provider without_default_tags évite l'ajout automatique
# de tags sur le rôle IAM.
#
# C'est important avec ton compte AWS, car nous avons déjà vu
# que ton utilisateur SSO pouvait être bloqué par iam:TagRole.
resource "aws_iam_role" "pdf_processor" {
  provider = aws.without_default_tags

  name = "${local.name_prefix}_role_lambda_pdf_processor"

  assume_role_policy = (
    data.aws_iam_policy_document.lambda_assume_role.json
  )
}


# ------------------------------------------------------------
# 3. Groupe de logs CloudWatch de la fonction Lambda
# ------------------------------------------------------------
# Les journaux de la Lambda seront conservés pendant 14 jours.
resource "aws_cloudwatch_log_group" "pdf_processor" {
  name = "/aws/lambda/${local.name_prefix}_lambda_pdf_processor"

  retention_in_days = 14

  tags = {
    Name = "${local.name_prefix}_logs_lambda_pdf_processor"
    Role = "lambda-logs"
  }
}


# ------------------------------------------------------------
# 4. Permissions nécessaires à la fonction Lambda
# ------------------------------------------------------------
data "aws_iam_policy_document" "lambda_pdf_processor" {

  # Autorise la Lambda à lire les objets du bucket source.
  statement {
    sid    = "ReadSourceObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.source.arn}/*"
    ]
  }

  # Autorise la Lambda à écrire les fichiers traités
  # dans le bucket de destination.
  statement {
    sid    = "WriteDestinationObjects"
    effect = "Allow"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.destination.arn}/*"
    ]
  }

  # Autorise la Lambda à écrire ses journaux dans CloudWatch.
  statement {
    sid    = "WriteLambdaLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.pdf_processor.arn}:*"
    ]
  }
}


# ------------------------------------------------------------
# 5. Création de la politique IAM gérée
# ------------------------------------------------------------
# On utilise une politique IAM gérée et non une politique inline.
#
# Cela évite iam:PutRolePolicy, permission qui avait provoqué
# une erreur pendant le TP1.
resource "aws_iam_policy" "lambda_pdf_processor" {
  provider = aws.without_default_tags

  name        = "${local.name_prefix}_policy_lambda_pdf_processor"
  description = "Accès S3 et CloudWatch Logs pour la Lambda du TP2"

  policy = data.aws_iam_policy_document.lambda_pdf_processor.json
}


# ------------------------------------------------------------
# 6. Association de la politique au rôle Lambda
# ------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "lambda_pdf_processor" {
  role       = aws_iam_role.pdf_processor.name
  policy_arn = aws_iam_policy.lambda_pdf_processor.arn
}
