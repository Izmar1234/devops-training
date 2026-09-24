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

variable "availability_zone" {
  description = "Zone de disponibilité des subnets"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Bloc CIDR du subnet public"
  type        = string
}

variable "private_subnet_cidr" {
  description = "Bloc CIDR du subnet privé"
  type        = string
}

variable "name_prefix" {
  description = "Préfixe utilisé pour nommer les ressources réseau"
  type        = string
}
