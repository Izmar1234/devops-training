variable "aws_region" {
  description = "Région AWS utilisée pour le TP2."
  type        = string
  default     = "eu-west-3"

  validation {
    condition     = var.aws_region == "eu-west-3"
    error_message = "Le TP doit être déployé dans eu-west-3."
  }
}

variable "last_name" {
  description = "Nom utilisé pour nommer les ressources."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,29}$", var.last_name))
    error_message = "Le nom doit être en minuscules, sans espace ni accent."
  }
}

variable "first_name" {
  description = "Prénom utilisé pour nommer les ressources."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,29}$", var.first_name))
    error_message = "Le prénom doit être en minuscules, sans espace ni accent."
  }
}

variable "expiration_days" {
  description = "Durée de conservation des PDF dans S3."
  type        = number
  default     = 7

  validation {
    condition     = var.expiration_days == 7
    error_message = "Le TP exige une conservation de 7 jours."
  }
}

variable "lambda_runtime" {
  description = "Runtime Python de la fonction Lambda."
  type        = string
  default     = "python3.12"

  validation {
    condition     = var.lambda_runtime == "python3.12"
    error_message = "Ce projet utilise Python 3.12."
  }
}
