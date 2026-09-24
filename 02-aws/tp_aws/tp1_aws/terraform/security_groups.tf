resource "aws_security_group" "nginx" {
  name        = "${local.name_prefix}_sg_nginx"
  description = "Autorise HTTP vers le serveur Nginx public"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    description = "HTTP depuis le CIDR autorise"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.web_ingress_cidr]
  }

  egress {
    description = "Autorise les connexions sortantes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}_sg_nginx"
    Role = "nginx"
  }
}

resource "aws_security_group" "apache" {
  name        = "${local.name_prefix}_sg_apache"
  description = "Autorise HTTP vers Apache uniquement depuis Nginx"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    description     = "HTTP depuis le Security Group Nginx"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.nginx.id]
  }

  egress {
    description = "Autorise les connexions sortantes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}_sg_apache"
    Role = "apache"
  }
}