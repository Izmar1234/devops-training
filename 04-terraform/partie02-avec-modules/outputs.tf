output "docker_instance_id" {
  description = "Identifiant de l'EC2 publique Docker"
  value       = module.compute.docker_instance_id
}

output "docker_public_ip" {
  description = "Adresse IPv4 publique de l'EC2 Docker"
  value       = module.compute.docker_public_ip
}

output "docker_private_ip" {
  description = "Adresse IPv4 privée de l'EC2 Docker"
  value       = module.compute.docker_private_ip
}

output "nodejs_instance_id" {
  description = "Identifiant de l'EC2 privée Node.js"
  value       = module.compute.nodejs_instance_id
}

output "nodejs_private_ip" {
  description = "Adresse IPv4 privée de l'EC2 Node.js"
  value       = module.compute.nodejs_private_ip
}

output "public_subnet_id" {
  description = "Identifiant du subnet public"
  value       = module.network.public_subnet_id
}

output "private_subnet_id" {
  description = "Identifiant du subnet privé"
  value       = module.network.private_subnet_id
}

output "remote_state_location" {
  description = "Emplacement logique du state distant"
  value       = "s3://techmind-terraform-state/izmar_modules/terraform.tfstate"
}

output "first_bucket_name" {
  description = "Nom du premier bucket S3"
  value       = module.storage.first_bucket_name
}

output "second_bucket_name" {
  description = "Nom du second bucket S3"
  value       = module.storage.second_bucket_name
}

output "first_bucket_arn" {
  description = "ARN du premier bucket S3"
  value       = module.storage.first_bucket_arn
}

output "second_bucket_arn" {
  description = "ARN du second bucket S3"
  value       = module.storage.second_bucket_arn
}

output "scheduler_lambda_name" {
  description = "Nom de la Lambda de démarrage et d'arrêt"
  value       = module.scheduler.lambda_function_name
}

output "scheduler_lambda_arn" {
  description = "ARN de la Lambda de démarrage et d'arrêt"
  value       = module.scheduler.lambda_function_arn
}

output "scheduler_log_group_name" {
  description = "Groupe CloudWatch Logs de la Lambda"
  value       = module.scheduler.lambda_log_group_name
}

output "start_schedule_name" {
  description = "Nom de la planification de démarrage"
  value       = module.scheduler.start_schedule_name
}

output "stop_schedule_name" {
  description = "Nom de la planification d'arrêt"
  value       = module.scheduler.stop_schedule_name
}
