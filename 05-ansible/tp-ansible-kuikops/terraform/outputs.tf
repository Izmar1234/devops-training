output "vpc_id" {
  description = "Identifiant du VPC existant"
  value       = data.aws_vpc.techmind.id
}

output "public_subnet_id" {
  description = "Identifiant du subnet public créé"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "Identifiant du subnet privé créé"
  value       = aws_subnet.private.id
}

output "public_route_table_id" {
  description = "Identifiant de la table de routage publique"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "Identifiant de la table de routage privée"
  value       = aws_route_table.private.id
}

output "ssh_key_name" {
  description = "Nom de la paire de clés SSH enregistrée dans AWS"
  value       = aws_key_pair.admin.key_name
}
output "fronts_security_group_id" {
  description = "Security Group des serveurs Front"
  value       = aws_security_group.fronts.id
}

output "jenkins_security_group_id" {
  description = "Security Group Jenkins"
  value       = aws_security_group.jenkins.id
}

output "glpi_app_security_group_id" {
  description = "Security Group de GLPI"
  value       = aws_security_group.glpi_app.id
}

output "glpi_db_security_group_id" {
  description = "Security Group de MariaDB"
  value       = aws_security_group.glpi_db.id
}

output "ubuntu_ami_id" {
  description = "AMI Ubuntu sélectionnée automatiquement"
  value       = data.aws_ami.ubuntu.id
}

output "front_01_public_ip" {
  description = "Adresse IP publique de front-01"
  value       = aws_instance.front_01.public_ip
}

output "front_01_private_ip" {
  description = "Adresse IP privée de front-01"
  value       = aws_instance.front_01.private_ip
}

output "front_02_public_ip" {
  description = "Adresse IP publique de front-02"
  value       = aws_instance.front_02.public_ip
}

output "front_02_private_ip" {
  description = "Adresse IP privée de front-02"
  value       = aws_instance.front_02.private_ip
}

output "glpi_app_public_ip" {
  description = "Adresse IP publique de glpi-app"
  value       = aws_instance.glpi_app.public_ip
}

output "glpi_app_private_ip" {
  description = "Adresse IP privée de glpi-app"
  value       = aws_instance.glpi_app.private_ip
}

output "glpi_db_private_ip" {
  description = "Adresse IP privée de glpi-db"
  value       = aws_instance.glpi_db.private_ip
}
output "front_01_ebs_volumes" {
  description = "Volumes EBS supplémentaires de front-01"

  value = {
    web  = aws_ebs_volume.front_01_web.id
    logs = aws_ebs_volume.front_01_logs.id
  }
}

output "front_02_ebs_volumes" {
  description = "Volumes EBS supplémentaires de front-02"

  value = {
    web  = aws_ebs_volume.front_02_web.id
    logs = aws_ebs_volume.front_02_logs.id
  }
}

