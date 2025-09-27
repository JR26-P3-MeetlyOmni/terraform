output "frontend_param_arn" {
  value = aws_ssm_parameter.frontend_api_base_url.arn
}

output "backend_connection_param_arn" {
  value     = aws_ssm_parameter.backend_db_connection_string.arn
  sensitive = true
}


