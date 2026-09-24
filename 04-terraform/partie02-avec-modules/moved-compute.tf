moved {
  from = aws_instance.docker
  to   = module.compute.aws_instance.docker
}

moved {
  from = aws_instance.nodejs
  to   = module.compute.aws_instance.nodejs
}
