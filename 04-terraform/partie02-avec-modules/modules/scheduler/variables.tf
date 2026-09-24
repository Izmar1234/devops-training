variable "name_prefix" {
  description = "Préfixe utilisé pour nommer les ressources du scheduler"
  type        = string
}

variable "owner" {
  description = "Valeur du tag Owner autorisée par la politique Lambda"
  type        = string
}

variable "docker_instance_id" {
  description = "Identifiant de l'instance Docker"
  type        = string
}

variable "docker_instance_arn" {
  description = "ARN de l'instance Docker"
  type        = string
}

variable "nodejs_instance_id" {
  description = "Identifiant de l'instance Node.js"
  type        = string
}

variable "nodejs_instance_arn" {
  description = "ARN de l'instance Node.js"
  type        = string
}

variable "lambda_source_file" {
  description = "Chemin du fichier Python source de la Lambda"
  type        = string
}

variable "lambda_output_path" {
  description = "Chemin de sortie de l'archive ZIP Lambda"
  type        = string
}
