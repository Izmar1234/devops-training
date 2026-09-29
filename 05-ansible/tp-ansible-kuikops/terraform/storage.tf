resource "aws_ebs_volume" "front_01_web" {
  availability_zone = var.availability_zone
  type              = "gp3"
  size              = var.web_volume_size
  encrypted         = true

  tags = {
    Name       = "${var.name_prefix}-front-01-web"
    Server     = "front-01"
    MountPoint = "/var/www"
  }
}

resource "aws_ebs_volume" "front_01_logs" {
  availability_zone = var.availability_zone
  type              = "gp3"
  size              = var.logs_volume_size
  encrypted         = true

  tags = {
    Name       = "${var.name_prefix}-front-01-logs"
    Server     = "front-01"
    MountPoint = "/var/log/apache2"
  }
}

resource "aws_ebs_volume" "front_02_web" {
  availability_zone = var.availability_zone
  type              = "gp3"
  size              = var.web_volume_size
  encrypted         = true

  tags = {
    Name       = "${var.name_prefix}-front-02-web"
    Server     = "front-02"
    MountPoint = "/var/www"
  }
}

resource "aws_ebs_volume" "front_02_logs" {
  availability_zone = var.availability_zone
  type              = "gp3"
  size              = var.logs_volume_size
  encrypted         = true

  tags = {
    Name       = "${var.name_prefix}-front-02-logs"
    Server     = "front-02"
    MountPoint = "/var/log/apache2"
  }
}

resource "aws_volume_attachment" "front_01_web" {
  instance_id = aws_instance.front_01.id
  volume_id   = aws_ebs_volume.front_01_web.id
  device_name = "/dev/sdf"
}

resource "aws_volume_attachment" "front_01_logs" {
  instance_id = aws_instance.front_01.id
  volume_id   = aws_ebs_volume.front_01_logs.id
  device_name = "/dev/sdg"
}

resource "aws_volume_attachment" "front_02_web" {
  instance_id = aws_instance.front_02.id
  volume_id   = aws_ebs_volume.front_02_web.id
  device_name = "/dev/sdf"
}

resource "aws_volume_attachment" "front_02_logs" {
  instance_id = aws_instance.front_02.id
  volume_id   = aws_ebs_volume.front_02_logs.id
  device_name = "/dev/sdg"
}