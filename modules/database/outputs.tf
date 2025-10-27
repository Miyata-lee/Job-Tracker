output "rds_address" {
  description = "RDS database address (hostname only)"
  value       = aws_db_instance.mysql.address
  sensitive   = true
}

output "rds_port" {
  description = "RDS database port"
  value       = aws_db_instance.mysql.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.mysql.db_name
}

output "db_username" {
  description = "Database master username"
  value       = aws_db_instance.mysql.username
  sensitive   = true
}

output "rds_resource_id" {
  description = "RDS resource ID"
  value       = aws_db_instance.mysql.resource_id
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value = aws_db_instance.mysql.endpoint
}
