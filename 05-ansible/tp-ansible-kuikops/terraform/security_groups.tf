resource "aws_security_group" "fronts" {
  name        = "${var.name_prefix}-sg-fronts"
  description = "Security Group des serveurs Front"
  vpc_id      = data.aws_vpc.techmind.id

  tags = {
    Name = "${var.name_prefix}-sg-fronts"
  }
}

resource "aws_vpc_security_group_ingress_rule" "fronts_ssh" {
  security_group_id = aws_security_group.fronts.id
  description       = "SSH depuis le poste administrateur"

  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_ipv4   = var.admin_cidr
}

resource "aws_vpc_security_group_ingress_rule" "fronts_http" {
  security_group_id = aws_security_group.fronts.id
  description       = "HTTP public pour les pages Apache"

  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "fronts_all_outbound" {
  security_group_id = aws_security_group.fronts.id
  description       = "Trafic sortant des serveurs Front"

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}
resource "aws_security_group" "jenkins" {
  name        = "${var.name_prefix}-sg-jenkins"
  description = "Acces a Jenkins depuis le poste administrateur"
  vpc_id      = data.aws_vpc.techmind.id

  tags = {
    Name = "${var.name_prefix}-sg-jenkins"
  }
}

resource "aws_vpc_security_group_ingress_rule" "jenkins_web" {
  security_group_id = aws_security_group.jenkins.id
  description       = "Interface Web Jenkins depuis le poste administrateur"

  ip_protocol = "tcp"
  from_port   = 8080
  to_port     = 8080
  cidr_ipv4   = var.admin_cidr
}

resource "aws_security_group" "glpi_app" {
  name        = "${var.name_prefix}-sg-glpi-app"
  description = "Security Group du serveur applicatif GLPI"
  vpc_id      = data.aws_vpc.techmind.id

  tags = {
    Name = "${var.name_prefix}-sg-glpi-app"
  }
}

resource "aws_vpc_security_group_ingress_rule" "glpi_app_ssh" {
  security_group_id = aws_security_group.glpi_app.id
  description       = "SSH depuis le poste administrateur"

  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_ipv4   = var.admin_cidr
}

resource "aws_vpc_security_group_ingress_rule" "glpi_app_http" {
  security_group_id = aws_security_group.glpi_app.id
  description       = "HTTP public pour GLPI"

  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "glpi_app_all_outbound" {
  security_group_id = aws_security_group.glpi_app.id
  description       = "Trafic sortant du serveur GLPI"

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}
resource "aws_security_group" "glpi_db" {
  name        = "${var.name_prefix}-sg-glpi-db"
  description = "Security Group du serveur MariaDB prive"
  vpc_id      = data.aws_vpc.techmind.id

  tags = {
    Name = "${var.name_prefix}-sg-glpi-db"
  }
}

resource "aws_vpc_security_group_ingress_rule" "glpi_db_mysql" {
  security_group_id = aws_security_group.glpi_db.id
  description       = "MariaDB uniquement depuis le serveur GLPI"

  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.glpi_app.id
}

resource "aws_vpc_security_group_ingress_rule" "glpi_db_ssh" {
  security_group_id = aws_security_group.glpi_db.id
  description       = "SSH depuis les serveurs Front utilises comme bastion"

  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.fronts.id
}

resource "aws_vpc_security_group_egress_rule" "glpi_db_all_outbound" {
  security_group_id = aws_security_group.glpi_db.id
  description       = "Sortie Internet via le NAT Gateway"

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}