# ============================================================
# IDENTITÉ ET RÉGION
# ============================================================

variable "aws_region" {
  description = "Région AWS utilisée par le TP"
  type        = string
  default     = "eu-west-3"

  validation {
    condition     = var.aws_region == "eu-west-3"
    error_message = "Le TP doit être réalisé dans eu-west-3."
  }
}

variable "last_name" {
  description = "Nom utilisé dans le nommage des ressources"
  type        = string

  validation {
    condition = (
      length(var.last_name) > 0 &&
      var.last_name == lower(var.last_name)
    )

    error_message = "Le nom doit être renseigné en minuscules."
  }
}

variable "first_name" {
  description = "Prénom utilisé dans le nommage des ressources"
  type        = string

  validation {
    condition = (
      length(var.first_name) > 0 &&
      var.first_name == lower(var.first_name)
    )

    error_message = "Le prénom doit être renseigné en minuscules."
  }
}


# ============================================================
# INFRASTRUCTURE EXISTANTE FOURNIE PAR LE TP
# ============================================================

variable "existing_vpc_id" {
  description = "Identifiant du VPC existant fourni par le TP"
  type        = string

  validation {
    condition     = can(regex("^vpc-[0-9a-f]+$", var.existing_vpc_id))
    error_message = "existing_vpc_id doit être un identifiant de VPC valide."
  }
}

variable "existing_internet_gateway_id" {
  description = "Identifiant de l'Internet Gateway existante"
  type        = string

  validation {
    condition = can(
      regex(
        "^igw-[0-9a-f]+$",
        var.existing_internet_gateway_id
      )
    )

    error_message = "L'identifiant de l'Internet Gateway est invalide."
  }
}

variable "existing_nat_gateway_id" {
  description = "Identifiant du NAT Gateway existant"
  type        = string

  validation {
    condition = can(
      regex(
        "^nat-[0-9a-f]+$",
        var.existing_nat_gateway_id
      )
    )

    error_message = "L'identifiant du NAT Gateway est invalide."
  }
}

variable "ssm_instance_profile_name" {
  description = "Profil IAM existant à attacher aux instances EC2"
  type        = string
  default     = "AmazonEC2RoleForSSM"
}


# ============================================================
# CONFIGURATION DEMANDÉE POUR LES INSTANCES EC2
# ============================================================

variable "instance_type" {
  description = "Type des instances EC2"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = var.instance_type == "t3.micro"
    error_message = "Le TP demande le type d'instance t3.micro."
  }
}

variable "root_volume_size" {
  description = "Taille du disque système en Gio"
  type        = number
  default     = 8

  validation {
    condition     = var.root_volume_size == 8
    error_message = "Le TP demande un disque système de 8 Gio."
  }
}

# ============================================================
# CONFIGURATION RÉSEAU DU NOUVEAU TP
# ============================================================

variable "availability_zone" {
  description = "Zone de disponibilité utilisée par le TP"
  type        = string
  default     = "eu-west-3a"

  validation {
    condition     = var.availability_zone == "eu-west-3a"
    error_message = "La partie 1 utilise la zone eu-west-3a."
  }
}

variable "public_subnet_cidr" {
  description = "Bloc CIDR du subnet public"
  type        = string

  validation {
    condition     = can(cidrhost(var.public_subnet_cidr, 1))
    error_message = "Le CIDR du subnet public doit être valide."
  }
}

variable "private_subnet_cidr" {
  description = "Bloc CIDR du subnet privé"
  type        = string

  validation {
    condition     = can(cidrhost(var.private_subnet_cidr, 1))
    error_message = "Le CIDR du subnet privé doit être valide."
  }
}

# ============================================================
# CONFIGURATION SSH
# ============================================================

variable "ssh_public_key_path" {
  description = "Chemin local vers la clé publique SSH"
  type        = string

  validation {
    condition = (
      length(var.ssh_public_key_path) > 0
    )

    error_message = "Le chemin de la clé publique SSH est obligatoire."
  }
}

variable "allowed_ssh_cidr" {
  description = "Adresse IPv4 autorisée à se connecter en SSH"
  type        = string

  validation {
    condition = (
      can(cidrhost(var.allowed_ssh_cidr, 0)) &&
      can(regex("/32$", var.allowed_ssh_cidr))
    )

    error_message = "allowed_ssh_cidr doit être une adresse IPv4 au format X.X.X.X/32."
  }
}
