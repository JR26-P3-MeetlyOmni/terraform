locals {
  base_name = "${var.log_group_prefix}/${var.name_prefix}/${var.env}"
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "${local.base_name}/${var.frontend_log_group_suffix}"
  retention_in_days = var.retention_in_days
}

resource "aws_cloudwatch_log_group" "backend" {
  name              = "${local.base_name}/${var.backend_log_group_suffix}"
  retention_in_days = var.retention_in_days
}
