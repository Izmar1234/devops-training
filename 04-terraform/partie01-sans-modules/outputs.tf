output "docker_instance_id" {
  description = "Identifiant de l'EC2 publique Docker"
  value       = aws_instance.docker.id
}

output "docker_public_ip" {
  description = "Adresse IPv4 publique de l'EC2 Docker"
  value       = aws_instance.docker.public_ip
}

output "docker_private_ip" {
  description = "Adresse IPv4 privée de l'EC2 Docker"
  value       = aws_instance.docker.private_ip
}

output "nodejs_instance_id" {
  description = "Identifiant de l'EC2 privée Node.js"
  value       = aws_instance.nodejs.id
}

output "nodejs_private_ip" {
  description = "Adresse IPv4 privée de l'EC2 Node.js"
  value       = aws_instance.nodejs.private_ip
}

output "public_subnet_id" {
  description = "Identifiant du subnet public"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "Identifiant du subnet privé"
  value       = aws_subnet.private.id
}

output "remote_state_location" {
  description = "Emplacement logique du state distant"
  value       = "s3://techmind-terraform-state/izmar/terraform.tfstate"
}
