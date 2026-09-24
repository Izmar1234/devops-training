output "first_bucket_name" {
  description = "Nom du premier bucket S3"
  value       = aws_s3_bucket.first.id
}

output "second_bucket_name" {
  description = "Nom du second bucket S3"
  value       = aws_s3_bucket.second.id
}

output "first_bucket_arn" {
  description = "ARN du premier bucket S3"
  value       = aws_s3_bucket.first.arn
}

output "second_bucket_arn" {
  description = "ARN du second bucket S3"
  value       = aws_s3_bucket.second.arn
}
