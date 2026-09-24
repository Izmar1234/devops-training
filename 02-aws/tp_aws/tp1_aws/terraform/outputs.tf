output "amazon_linux_2023_ami" {
  description = "AMI Amazon Linux 2023."
  value       = nonsensitive(data.aws_ssm_parameter.amazon_linux_2023_ami.value)
}

output "aws_account_id" {
  description = "Compte AWS utilisé."
  value       = data.aws_caller_identity.current.account_id
}

output "selected_region" {
  description = "Région AWS."
  value       = var.aws_region
}

output "resource_name_prefix" {
  description = "Préfixe de nommage."
  value       = local.name_prefix
}

output "existing_vpc_id" {
  description = "VPC existant."
  value       = data.aws_vpc.existing.id
}

output "existing_vpc_cidr" {
  description = "CIDR du VPC."
  value       = data.aws_vpc.existing.cidr_block
}

output "existing_internet_gateway_id" {
  description = "Internet Gateway existante."
  value       = data.aws_internet_gateway.existing.id
}

output "nat_gateway_id" {
  description = "NAT Gateway partagée."
  value       = data.aws_nat_gateway.existing.id
}

output "ssm_instance_profile_name" {
  description = "Instance Profile SSM."
  value       = data.aws_iam_instance_profile.ssm.name
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "public_subnet_cidr" {
  value = aws_subnet.public.cidr_block
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "private_subnet_cidr" {
  value = aws_subnet.private.cidr_block
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "nginx_instance_id" {
  value = aws_instance.nginx.id
}

output "nginx_public_ip" {
  value = aws_instance.nginx.public_ip
}

output "nginx_private_ip" {
  value = aws_instance.nginx.private_ip
}

output "nginx_url" {
  value = "http://${aws_instance.nginx.public_ip}"
}

output "apache_instance_id" {
  value = aws_instance.apache.id
}

output "apache_private_ip" {
  value = aws_instance.apache.private_ip
}

output "scheduler_lambda_name" {
  value = aws_lambda_function.scheduler.function_name
}

output "scheduler_lambda_log_group" {
  value = aws_cloudwatch_log_group.lambda_scheduler.name
}

output "start_schedule_name" {
  value = aws_scheduler_schedule.start.name
}

output "stop_schedule_name" {
  value = aws_scheduler_schedule.stop.name
}