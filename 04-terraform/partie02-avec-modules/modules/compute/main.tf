# ============================================================
# SERVEUR PUBLIC DOCKER
# ============================================================

resource "aws_instance" "docker" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = var.public_subnet_id

  vpc_security_group_ids = [
    var.public_security_group_id
  ]

  key_name             = var.key_pair_name
  iam_instance_profile = var.iam_instance_profile_name

  user_data                   = var.docker_user_data
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
      Name = "${var.name_prefix}_ebs_docker"
      Role = "docker-root-volume"
    }
  }

  tags = {
    Name     = "${var.name_prefix}_ec2_docker"
    Role     = "docker-server"
    Network  = "public"
    Schedule = "iac-office-hours"
  }
}


# ============================================================
# SERVEUR PRIVÉ NODE.JS
# ============================================================

resource "aws_instance" "nodejs" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = var.private_subnet_id

  vpc_security_group_ids = [
    var.private_security_group_id
  ]

  associate_public_ip_address = false

  key_name             = var.key_pair_name
  iam_instance_profile = var.iam_instance_profile_name

  user_data                   = var.nodejs_user_data
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
      Name = "${var.name_prefix}_ebs_nodejs"
      Role = "nodejs-root-volume"
    }
  }

  tags = {
    Name     = "${var.name_prefix}_ec2_nodejs"
    Role     = "nodejs-server"
    Network  = "private"
    Schedule = "iac-office-hours"
  }
}
