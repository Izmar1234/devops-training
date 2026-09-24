variable "aws_region" {
  description = "Région AWS du TP."
  type        = string
  default     = "eu-west-3"

  validation {
    condition     = var.aws_region == "eu-west-3"
    error_message = "Le TP doit être déployé dans eu-west-3."
  }
}

variable "vpc_id" {
  description = "Identifiant du VPC existant."
  type        = string
  default     = "vpc-02855c98755e6b058"
}

variable "internet_gateway_id" {
  description = "Identifiant de l'Internet Gateway existante."
  type        = string
  default     = "igw-0fed3cfd38607d94b"
}

variable "nat_gateway_id" {
  description = "Identifiant de la NAT Gateway partagée."
  type        = string
  default     = "nat-1522f5fbe634d3413"
}

variable "availability_zone" {
  description = "Availability Zone unique du TP."
  type        = string
  default     = "eu-west-3a"

  validation {
    condition     = var.availability_zone == "eu-west-3a"
    error_message = "Le TP utilise uniquement eu-west-3a."
  }
}

variable "public_subnet_cidr" {
  description = "CIDR du subnet public."
  type        = string
  default     = "10.0.12.0/24"

  validation {
    condition     = can(cidrhost(var.public_subnet_cidr, 1))
    error_message = "Le CIDR public doit être valide."
  }
}

variable "private_subnet_cidr" {
  description = "CIDR du subnet privé."
  type        = string
  default     = "10.0.11.0/24"

  validation {
    condition     = can(cidrhost(var.private_subnet_cidr, 1))
    error_message = "Le CIDR privé doit être valide."
  }
}

variable "last_name" {
  description = "Nom utilisé dans le nommage."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,29}$", var.last_name))
    error_message = "Le nom doit être en minuscules, sans espace ni accent."
  }
}

variable "first_name" {
  description = "Prénom utilisé dans le nommage."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,29}$", var.first_name))
    error_message = "Le prénom doit être en minuscules, sans espace ni accent."
  }
}

variable "instance_type" {
  description = "Type EC2 demandé par le TP."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = var.instance_type == "t3.micro"
    error_message = "Le TP exige le type t3.micro."
  }
}

variable "root_volume_size" {
  description = "Taille du disque racine en Gio."
  type        = number
  default     = 8

  validation {
    condition     = var.root_volume_size == 8
    error_message = "Le TP exige un disque de 8 Gio."
  }
}

variable "web_ingress_cidr" {
  description = "CIDR autorisé à accéder à Nginx."
  type        = string

  validation {
    condition     = can(cidrhost(var.web_ingress_cidr, 0))
    error_message = "Le CIDR d'accès web doit être valide."
  }
}