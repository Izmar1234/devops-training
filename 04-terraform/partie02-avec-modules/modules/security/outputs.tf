output "key_pair_name" {
  description = "Nom de la paire de clés SSH enregistrée dans AWS"
  value       = aws_key_pair.main.key_name
}

output "public_security_group_id" {
  description = "Identifiant du Security Group du serveur public"
  value       = aws_security_group.public_server.id
}

output "private_security_group_id" {
  description = "Identifiant du Security Group du serveur privé"
  value       = aws_security_group.private_server.id
}
