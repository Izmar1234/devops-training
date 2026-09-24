locals {
  name_prefix = "tech_mind_${var.last_name}_${var.first_name}"

  bucket_prefix = "tech-mind-${data.aws_caller_identity.current.account_id}-${var.last_name}-${var.first_name}"

  source_bucket_name = (
    "${local.bucket_prefix}-pdf-source"
  )

  destination_bucket_name = (
    "${local.bucket_prefix}-pdf-destination"
  )

  common_tags = {
    Project     = "tech_mind_aws_tp2"
    Owner       = "${var.last_name}_${var.first_name}"
    Environment = "test"
    ManagedBy   = "Terraform"
  }
}
