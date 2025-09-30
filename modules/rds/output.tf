output "db_instance_id" {
  value = length(aws_db_instance.this) > 0 ? aws_db_instance.this[0].id : null
}

output "db_instance_arn" {
  value = length(aws_db_instance.this) > 0 ? aws_db_instance.this[0].arn : null
}

output "db_instance_endpoint" {
  value = length(aws_db_instance.this) > 0 ? aws_db_instance.this[0].endpoint : null
}

output "db_instance_port" {
  value = length(aws_db_instance.this) > 0 ? aws_db_instance.this[0].port : null
}

output "db_subnet_group_name" {
  value = length(aws_db_subnet_group.this) > 0 ? aws_db_subnet_group.this[0].name : null
}

output "security_group_id" {
  value = length(aws_security_group.this) > 0 ? aws_security_group.this[0].id : null
}

output "credentials_secret_arn" {
  value = length(aws_secretsmanager_secret.master) > 0 ? aws_secretsmanager_secret.master[0].arn : null
}

output "connection_string" {
  value = local.connection_string
}
