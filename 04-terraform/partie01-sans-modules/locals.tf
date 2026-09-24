locals {
  # Préfixe général conforme au format demandé par le TP.
  name_prefix = (
    "tech_mind_iac_${var.last_name}_${var.first_name}"
  )

  # Identité utilisée dans les tags et les politiques.
  owner = "${var.last_name}_${var.first_name}"

  # Préfixe compatible avec les règles de nommage S3.
  # Les noms de buckets S3 n'acceptent pas les underscores.
  bucket_name_prefix = (
    "tech-mind-iac-${data.aws_caller_identity.current.account_id}-${var.last_name}-${var.first_name}"
  )

  # Tags automatiquement appliqués par le provider principal.
  common_tags = {
    Project     = "tech_mind_iac"
    Owner       = local.owner
    Environment = "test"
    ManagedBy   = "Terraform"
    Part        = "without-modules"
  }
}
