locals {
  db_instance = length(aws_db_instance.main) > 0 ? aws_db_instance.main[0] : null
}

output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = local.db_instance != null ? local.db_instance.endpoint : null
}

output "db_port" {
  description = "RDS instance port"
  value       = local.db_instance != null ? local.db_instance.port : null
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = local.db_instance != null ? local.db_instance.id : null
}