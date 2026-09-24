

resource "aws_instance" "docker" {
  ami           = data.aws_ssm_parameter.amazon_linux_2023_ami.value
  instance_type = var.instance_type

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.public_server.id
  ]



  key_name = aws_key_pair.main.key_name

  # Profil IAM existant fourni par le TP.
  iam_instance_profile = (
    data.aws_iam_instance_profile.ssm.name
  )

  # Installation automatique de Docker et SSM Agent.
  user_data = file(
    "${path.module}/user-data/docker.sh"
  )

  # Une modification du script provoquera le remplacement
  # de l'instance afin de rejouer le script de démarrage.
  user_data_replace_on_change = true

  # Imposer IMDSv2 pour protéger le service de métadonnées.
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
      Name = "${local.name_prefix}_ebs_docker"
      Role = "docker-root-volume"
    }
  }

  tags = {
    Name     = "${local.name_prefix}_ec2_docker"
    Role     = "docker-server"
    Network  = "public"
    Schedule = "iac-office-hours"
  }

  # Le serveur ne doit démarrer qu'après la création de sa route
  # Internet et de l'association de sa table de routage.
  depends_on = [
    aws_route.public_internet,
    aws_route_table_association.public
  ]
}


# ============================================================
# SERVEUR PRIVÉ NODE.JS
# ============================================================

resource "aws_instance" "nodejs" {
  ami           = data.aws_ssm_parameter.amazon_linux_2023_ami.value
  instance_type = var.instance_type

  subnet_id = aws_subnet.private.id

  vpc_security_group_ids = [
    aws_security_group.private_server.id
  ]

  # Le serveur privé ne doit pas recevoir d'adresse IP publique.
  associate_public_ip_address = false

  key_name = aws_key_pair.main.key_name

  # Même profil IAM SSM sur le serveur privé.
  iam_instance_profile = (
    data.aws_iam_instance_profile.ssm.name
  )

  # Installation automatique de Node.js et SSM Agent.
  user_data = file(
    "${path.module}/user-data/nodejs.sh"
  )

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
      Name = "${local.name_prefix}_ebs_nodejs"
      Role = "nodejs-root-volume"
    }
  }

  tags = {
    Name     = "${local.name_prefix}_ec2_nodejs"
    Role     = "nodejs-server"
    Network  = "private"
    Schedule = "iac-office-hours"
  }

  # Le serveur privé a besoin de la route NAT pour installer
  # Node.js et communiquer avec AWS Systems Manager.
  depends_on = [
    aws_route.private_internet,
    aws_route_table_association.private
  ]
}
