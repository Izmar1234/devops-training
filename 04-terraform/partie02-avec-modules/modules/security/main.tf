# ============================================================
# CLÉ PUBLIQUE SSH
# ============================================================

resource "aws_key_pair" "main" {
  key_name   = "${var.name_prefix}_key_pair"
  public_key = var.ssh_public_key

  tags = {
    Name = "${var.name_prefix}_key_pair"
    Role = "ssh-access"
  }
}


# ============================================================
# GROUPE DE SÉCURITÉ DU SERVEUR PUBLIC
# ============================================================

resource "aws_security_group" "public_server" {
  name        = "${var.name_prefix}_sg_public_server"
  description = "Security group du serveur public Docker"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}_sg_public_server"
    Role = "public-server"
  }
}

resource "aws_vpc_security_group_ingress_rule" "public_ssh" {
  security_group_id = aws_security_group.public_server.id

  description = "SSH depuis le poste Ubuntu autorise"

  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_ipv4   = var.allowed_ssh_cidr

  tags = {
    Name = "${var.name_prefix}_sgr_public_ssh"
    Role = "public-ssh"
  }
}

resource "aws_vpc_security_group_egress_rule" "public_all_outbound" {
  security_group_id = aws_security_group.public_server.id

  description = "Connexions sortantes du serveur public"

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "${var.name_prefix}_sgr_public_egress"
    Role = "public-egress"
  }
}


# ============================================================
# GROUPE DE SÉCURITÉ DU SERVEUR PRIVÉ
# ============================================================

resource "aws_security_group" "private_server" {
  name        = "${var.name_prefix}_sg_private_server"
  description = "Security group du serveur prive Node.js"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}_sg_private_server"
    Role = "private-server"
  }
}

resource "aws_vpc_security_group_ingress_rule" "private_ssh_from_public" {
  security_group_id = aws_security_group.private_server.id

  description = "SSH depuis le serveur public uniquement"

  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22

  referenced_security_group_id = aws_security_group.public_server.id

  tags = {
    Name = "${var.name_prefix}_sgr_private_ssh"
    Role = "private-ssh"
  }
}

resource "aws_vpc_security_group_egress_rule" "private_all_outbound" {
  security_group_id = aws_security_group.private_server.id

  description = "Connexions sortantes du serveur prive via NAT"

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "${var.name_prefix}_sgr_private_egress"
    Role = "private-egress"
  }
}
