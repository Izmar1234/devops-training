variable "ami_id" {
  description = "Identifiant de l'AMI utilisée par les instances"
  type        = string
}

variable "instance_type" {
  description = "Type des instances EC2"
  type        = string
}

variable "root_volume_size" {
  description = "Taille du volume racine en Gio"
  type        = number
}

variable "public_subnet_id" {
  description = "Identifiant du subnet public"
  type        = string
}

variable "private_subnet_id" {
  description = "Identifiant du subnet privé"
  type        = string
}

variable "public_security_group_id" {
  description = "Security Group attaché au serveur Docker"
  type        = string
}

variable "private_security_group_id" {
  description = "Security Group attaché au serveur Node.js"
  type        = string
}

variable "key_pair_name" {
  description = "Nom de la paire de clés SSH"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Nom du profil IAM permettant l'accès SSM"
  type        = string
}

variable "docker_user_data" {
  description = "Contenu du script User Data du serveur Docker"
  type        = string
}

variable "nodejs_user_data" {
  description = "Contenu du script User Data du serveur Node.js"
  type        = string
}

variable "name_prefix" {
  description = "Préfixe utilisé pour nommer les ressources EC2"
  type        = string
}
