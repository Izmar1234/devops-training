variable "vpc_id" {
  description = "Identifiant du VPC contenant les groupes de sécurité"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "Bloc CIDR autorisé à se connecter en SSH au serveur public"
  type        = string
}

variable "ssh_public_key" {
  description = "Contenu de la clé publique SSH enregistrée dans AWS"
  type        = string
}

variable "name_prefix" {
  description = "Préfixe utilisé pour nommer les ressources de sécurité"
  type        = string
}
