output "lambda_function_name" {
  description = "Nom de la fonction Lambda scheduler"
  value       = aws_lambda_function.scheduler.function_name
}

output "lambda_function_arn" {
  description = "ARN de la fonction Lambda scheduler"
  value       = aws_lambda_function.scheduler.arn
}

output "lambda_log_group_name" {
  description = "Nom du groupe CloudWatch Logs de la Lambda"
  value       = aws_cloudwatch_log_group.scheduler.name
}

output "start_schedule_name" {
  description = "Nom de la planification de démarrage"
  value       = aws_scheduler_schedule.start.name
}

output "stop_schedule_name" {
  description = "Nom de la planification d'arrêt"
  value       = aws_scheduler_schedule.stop.name
}
