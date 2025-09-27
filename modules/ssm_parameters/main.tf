resource "aws_ssm_parameter" "frontend_api_base_url" {
  name  = "/${var.name_prefix}/${var.env}/frontend/API_BASE_URL"
  type  = "String"
  value = var.frontend_api_base_url
}

resource "aws_ssm_parameter" "backend_db_connection_string" {
  name  = "/${var.name_prefix}/${var.env}/backend/DB_CONNECTION_STRING"
  type  = "SecureString"
  value = var.backend_db_connection_string
}


