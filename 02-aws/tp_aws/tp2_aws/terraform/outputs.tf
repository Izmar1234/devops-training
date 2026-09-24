output "aws_account_id" {
  description = "Compte AWS utilisé."
  value       = data.aws_caller_identity.current.account_id
}

output "selected_region" {
  description = "Région AWS du déploiement."
  value       = var.aws_region
}

output "resource_name_prefix" {
  description = "Préfixe utilisé pour les ressources."
  value       = local.name_prefix
}

output "source_bucket_name" {
  description = "Nom prévu pour le bucket source."
  value       = local.source_bucket_name
}

output "destination_bucket_name" {
  description = "Nom prévu pour le bucket destination."
  value       = local.destination_bucket_name
}

output "source_bucket_arn" {
  description = "ARN du bucket source."
  value       = aws_s3_bucket.source.arn
}

output "destination_bucket_arn" {
  description = "ARN du bucket destination."
  value       = aws_s3_bucket.destination.arn
}

output "source_bucket_encryption" {
  description = "Chiffrement configuré sur le bucket source."
  value       = "AES256"
}

output "destination_bucket_encryption" {
  description = "Chiffrement configuré sur le bucket destination."
  value       = "AES256"
}

output "object_expiration_days" {
  description = "Durée de conservation des objets."
  value       = var.expiration_days
}

output "lambda_function_name" {
  description = "Nom de la fonction Lambda de traitement des PDF"
  value       = aws_lambda_function.pdf_processor.function_name
}

output "lambda_function_arn" {
  description = "ARN de la fonction Lambda de traitement des PDF"
  value       = aws_lambda_function.pdf_processor.arn
}

output "lambda_log_group_name" {
  description = "Nom du groupe CloudWatch Logs de la Lambda"
  value       = aws_cloudwatch_log_group.pdf_processor.name
}
