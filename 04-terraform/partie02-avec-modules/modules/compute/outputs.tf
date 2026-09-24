output "docker_instance_id" {
  description = "Identifiant de l'instance Docker"
  value       = aws_instance.docker.id
}

output "docker_instance_arn" {
  description = "ARN de l'instance Docker"
  value       = aws_instance.docker.arn
}

output "docker_public_ip" {
  description = "Adresse IPv4 publique de l'instance Docker"
  value       = aws_instance.docker.public_ip
}

output "docker_private_ip" {
  description = "Adresse IPv4 privée de l'instance Docker"
  value       = aws_instance.docker.private_ip
}

output "nodejs_instance_id" {
  description = "Identifiant de l'instance Node.js"
  value       = aws_instance.nodejs.id
}

output "nodejs_instance_arn" {
  description = "ARN de l'instance Node.js"
  value       = aws_instance.nodejs.arn
}

output "nodejs_private_ip" {
  description = "Adresse IPv4 privée de l'instance Node.js"
  value       = aws_instance.nodejs.private_ip
}
