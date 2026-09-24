# ============================================================
# GROUPE DE SÉCURITÉ DU SERVEUR PUBLIC DOCKER
# ============================================================

resource "aws_security_group" "public_server" {
  name = "${local.name_prefix}_sg_public_server"

  description = (
    "Security group du serveur public Docker"
  )

  vpc_id = var.existing_vpc_id

  tags = {
    Name = "${local.name_prefix}_sg_public_server"
    Role = "public-server"
  }
}


# Autoriser SSH vers le serveur public uniquement depuis
# l'adresse IPv4 publique définie dans terraform.tfvars.
resource "aws_vpc_security_group_ingress_rule" "public_ssh" {
  security_group_id = aws_security_group.public_server.id

  description = "SSH depuis le poste Ubuntu autorise"

  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22

  cidr_ipv4 = var.allowed_ssh_cidr

  tags = {
    Name = "${local.name_prefix}_sgr_public_ssh"
    Role = "public-ssh"
  }
}


# Autoriser les connexions sortantes du serveur public.
# Elles sont nécessaires pour installer Docker, appliquer
# les mises à jour et contacter les services SSM.
resource "aws_vpc_security_group_egress_rule" "public_all_outbound" {
  security_group_id = aws_security_group.public_server.id

  description = "Connexions sortantes du serveur public"

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "${local.name_prefix}_sgr_public_egress"
    Role = "public-egress"
  }
}


# ============================================================
# GROUPE DE SÉCURITÉ DU SERVEUR PRIVÉ NODE.JS
# ============================================================

resource "aws_security_group" "private_server" {
  name = "${local.name_prefix}_sg_private_server"

  description = (
    "Security group du serveur prive Node.js"
  )

  vpc_id = var.existing_vpc_id

  tags = {
    Name = "${local.name_prefix}_sg_private_server"
    Role = "private-server"
  }
}


# Le serveur privé accepte SSH uniquement depuis une instance
# possédant le groupe de sécurité du serveur public.
resource "aws_vpc_security_group_ingress_rule" "private_ssh_from_public" {
  security_group_id = aws_security_group.private_server.id

  description = "SSH depuis le serveur public uniquement"

  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22

  referenced_security_group_id = (
    aws_security_group.public_server.id
  )

  tags = {
    Name = "${local.name_prefix}_sgr_private_ssh"
    Role = "private-ssh"
  }
}


# Le serveur privé peut initier des connexions sortantes.
# Sa table de routage enverra ces connexions vers le NAT.
resource "aws_vpc_security_group_egress_rule" "private_all_outbound" {
  security_group_id = aws_security_group.private_server.id

  description = "Connexions sortantes du serveur prive via NAT"

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "${local.name_prefix}_sgr_private_egress"
    Role = "private-egress"
  }
}
