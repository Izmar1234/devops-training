# ============================================================
# FONCTION LAMBDA DE TRAITEMENT DES PDF
# ============================================================


# ------------------------------------------------------------
# 1. Création automatique de l'archive ZIP
# ------------------------------------------------------------
data "archive_file" "pdf_processor" {
  type = "zip"

  source_file = (
    "${path.module}/lambda/process_pdf.py"
  )

  output_path = (
    "${path.module}/lambda/process_pdf.zip"
  )
}


# ------------------------------------------------------------
# 2. Fonction AWS Lambda
# ------------------------------------------------------------
resource "aws_lambda_function" "pdf_processor" {
  function_name = "${local.name_prefix}_lambda_pdf_processor"
  description   = "Traite et renomme les PDF déposés dans le bucket source"

  filename = data.archive_file.pdf_processor.output_path

  source_code_hash = (
    data.archive_file.pdf_processor.output_base64sha256
  )

  role = aws_iam_role.pdf_processor.arn

  runtime = var.lambda_runtime
  handler = "process_pdf.lambda_handler"

  memory_size = 128
  timeout     = 30

  environment {
    variables = {
      DESTINATION_BUCKET = aws_s3_bucket.destination.id
      FILENAME_PREFIX    = "tech_mind_"
    }
  }

  tags = {
    Name = "${local.name_prefix}_lambda_pdf_processor"
    Role = "pdf-processor"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_pdf_processor,
    aws_cloudwatch_log_group.pdf_processor,
    aws_s3_bucket_server_side_encryption_configuration.destination
  ]
}
