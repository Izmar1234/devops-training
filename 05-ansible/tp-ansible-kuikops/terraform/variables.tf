variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "environment" {
  description = "Nom de l'environnement"
  type        = string
}

variable "owner" {
  description = "Propriétaire des ressources AWS"
  type        = string
}

variable "name_prefix" {
  description = "Préfixe commun utilisé pour nommer les ressources AWS"
  type        = string
}

variable "availability_zone" {
  description = "Zone de disponibilité utilisée pour les EC2 et les volumes EBS"
  type        = string
}

variable "vpc_id" {
  description = "Identifiant du VPC existant"
  type        = string
}

variable "internet_gateway_id" {
  description = "Identifiant de l'Internet Gateway existante"
  type        = string
}

variable "nat_gateway_id" {
  description = "Identifiant du NAT Gateway existant"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Bloc CIDR IPv4 du subnet public"
  type        = string

  validation {
    condition     = can(cidrhost(var.public_subnet_cidr, 0))
    error_message = "public_subnet_cidr doit être un bloc CIDR IPv4 valide."
  }
}

variable "private_subnet_cidr" {
  description = "Bloc CIDR IPv4 du subnet privé"
  type        = string

  validation {
    condition     = can(cidrhost(var.private_subnet_cidr, 0))
    error_message = "private_subnet_cidr doit être un bloc CIDR IPv4 valide."
  }
}

variable "admin_cidr" {
  description = "Adresse IPv4 autorisée à administrer les EC2"
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0))
    error_message = "admin_cidr doit être un bloc CIDR IPv4 valide."
  }
}

variable "ssh_public_key_path" {
  description = "Chemin local vers la clé SSH publique"
  type        = string
}

variable "front_01_instance_type" {
  description = "Type d'instance de front-01, qui hébergera aussi Jenkins"
  type        = string
}

variable "front_02_instance_type" {
  description = "Type d'instance de front-02"
  type        = string
}

variable "glpi_app_instance_type" {
  description = "Type d'instance du serveur applicatif GLPI"
  type        = string
}

variable "glpi_db_instance_type" {
  description = "Type d'instance du serveur MariaDB"
  type        = string
}

variable "root_volume_size" {
  description = "Taille du volume racine des EC2 en Gio"
  type        = number

  validation {
    condition     = var.root_volume_size >= 8
    error_message = "Le volume racine doit avoir une taille minimale de 8 Gio."
  }
}

variable "web_volume_size" {
  description = "Taille du volume EBS monté dans /var/www, en Gio"
  type        = number

  validation {
    condition     = var.web_volume_size >= 1
    error_message = "Le volume Web doit avoir une taille minimale de 1 Gio."
  }
}

variable "logs_volume_size" {
  description = "Taille du volume EBS monté dans /var/log/apache2, en Gio"
  type        = number

  validation {
    condition     = var.logs_volume_size >= 1
    error_message = "Le volume de logs doit avoir une taille minimale de 1 Gio."
  }
}