resource "aws_vpc_security_group_ingress_rule" "jenkins_webhook_https" {
  security_group_id = aws_security_group.jenkins.id
  description       = "HTTPS pour le webhook GitLab vers Jenkins"

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}

