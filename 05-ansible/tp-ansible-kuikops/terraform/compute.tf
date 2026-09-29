resource "aws_key_pair" "admin" {
  key_name = "${var.name_prefix}-key"

  public_key = file(
    pathexpand(var.ssh_public_key_path)
  )

  tags = {
    Name = "${var.name_prefix}-key"
  }
}

resource "aws_instance" "front_01" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.front_01_instance_type

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.fronts.id,
    aws_security_group.jenkins.id
  ]

  key_name = aws_key_pair.admin.key_name

  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name = "${var.name_prefix}-front-01-root"
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "${var.name_prefix}-front-01"
    Role = "front"
  }
}

resource "aws_instance" "front_02" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.front_02_instance_type

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.fronts.id
  ]

  key_name = aws_key_pair.admin.key_name

  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name = "${var.name_prefix}-front-02-root"
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "${var.name_prefix}-front-02"
    Role = "front"
  }
}

resource "aws_instance" "glpi_app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.glpi_app_instance_type

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.glpi_app.id
  ]

  key_name = aws_key_pair.admin.key_name

  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name = "${var.name_prefix}-glpi-app-root"
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "${var.name_prefix}-glpi-app"
    Role = "glpi-app"
  }
}

resource "aws_instance" "glpi_db" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.glpi_db_instance_type

  subnet_id = aws_subnet.private.id

  vpc_security_group_ids = [
    aws_security_group.glpi_db.id
  ]

  key_name = aws_key_pair.admin.key_name

  associate_public_ip_address = false

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name = "${var.name_prefix}-glpi-db-root"
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "${var.name_prefix}-glpi-db"
    Role = "glpi-db"
  }
}