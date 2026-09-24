resource "aws_instance" "apache" {
  ami           = nonsensitive(data.aws_ssm_parameter.amazon_linux_2023_ami.value)
  instance_type = var.instance_type

  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.apache.id]

  associate_public_ip_address = false

  iam_instance_profile = data.aws_iam_instance_profile.ssm.name

  user_data                   = file("${path.module}/user-data/apache.sh")
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name = "${local.name_prefix}_ebs_apache"
    }
  }

  credit_specification {
    cpu_credits = "standard"
  }

  instance_initiated_shutdown_behavior = "stop"

  tags = {
    Name     = "${local.name_prefix}_ec2_apache"
    Role     = "apache"
    Schedule = local.schedule_tag_value
  }

  lifecycle {
    precondition {
      condition     = data.aws_vpc.existing.cidr_block == "10.0.0.0/16"
      error_message = "Le VPC doit utiliser le CIDR 10.0.0.0/16."
    }
  }

  depends_on = [
    aws_route.private_internet,
    aws_route_table_association.private
  ]
}

resource "aws_instance" "nginx" {
  ami           = nonsensitive(data.aws_ssm_parameter.amazon_linux_2023_ami.value)
  instance_type = var.instance_type

  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.nginx.id]

  associate_public_ip_address = true

  iam_instance_profile = data.aws_iam_instance_profile.ssm.name

  user_data                   = file("${path.module}/user-data/nginx.sh")
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name = "${local.name_prefix}_ebs_nginx"
    }
  }

  credit_specification {
    cpu_credits = "standard"
  }

  instance_initiated_shutdown_behavior = "stop"

  tags = {
    Name     = "${local.name_prefix}_ec2_nginx"
    Role     = "nginx"
    Schedule = local.schedule_tag_value
  }

  depends_on = [
    aws_route.public_internet,
    aws_route_table_association.public
  ]
}