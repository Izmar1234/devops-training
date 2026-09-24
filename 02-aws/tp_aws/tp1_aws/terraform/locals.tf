locals {
  name_prefix = "tech_mind_${var.last_name}_${var.first_name}"

  common_tags = {
    Project     = "tech_mind_aws_tp1"
    Owner       = "${var.last_name}_${var.first_name}"
    Environment = "test"
    ManagedBy   = "Terraform"
  }

  schedule_tag_value = "office-hours"
}