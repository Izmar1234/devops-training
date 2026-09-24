moved {
  from = aws_key_pair.main
  to   = module.security.aws_key_pair.main
}

moved {
  from = aws_security_group.public_server
  to   = module.security.aws_security_group.public_server
}

moved {
  from = aws_security_group.private_server
  to   = module.security.aws_security_group.private_server
}

moved {
  from = aws_vpc_security_group_ingress_rule.public_ssh
  to   = module.security.aws_vpc_security_group_ingress_rule.public_ssh
}

moved {
  from = aws_vpc_security_group_egress_rule.public_all_outbound
  to   = module.security.aws_vpc_security_group_egress_rule.public_all_outbound
}

moved {
  from = aws_vpc_security_group_ingress_rule.private_ssh_from_public
  to   = module.security.aws_vpc_security_group_ingress_rule.private_ssh_from_public
}

moved {
  from = aws_vpc_security_group_egress_rule.private_all_outbound
  to   = module.security.aws_vpc_security_group_egress_rule.private_all_outbound
}
