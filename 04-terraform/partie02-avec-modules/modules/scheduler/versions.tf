terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"

      configuration_aliases = [
        aws.without_default_tags
      ]
    }

    archive = {
      source = "hashicorp/archive"
    }
  }
}
