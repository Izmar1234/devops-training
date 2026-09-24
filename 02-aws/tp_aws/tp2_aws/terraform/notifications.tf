# ============================================================
# DÉCLENCHEMENT AUTOMATIQUE S3 VERS LAMBDA
# ============================================================


# ------------------------------------------------------------
# 1. Autorisation donnée à Amazon S3
# ------------------------------------------------------------
# Cette ressource autorise uniquement notre bucket source
# à invoquer la fonction Lambda.
resource "aws_lambda_permission" "allow_source_bucket" {
  statement_id = "AllowExecutionFromSourceS3Bucket"

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pdf_processor.function_name
  principal     = "s3.amazonaws.com"

  source_arn     = aws_s3_bucket.source.arn
  source_account = data.aws_caller_identity.current.account_id
}


# ------------------------------------------------------------
# 2. Notification du bucket source
# ------------------------------------------------------------
# Lorsqu'un objet avec l'extension .pdf est créé dans le bucket
# source, Amazon S3 déclenche automatiquement la fonction Lambda.
resource "aws_s3_bucket_notification" "source_pdf_upload" {
  bucket = aws_s3_bucket.source.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.pdf_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".pdf"
  }

  depends_on = [
    aws_lambda_permission.allow_source_bucket
  ]
}
