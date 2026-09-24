output "public_subnet_id" {
  description = "Identifiant du subnet public"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "Identifiant du subnet privé"
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
