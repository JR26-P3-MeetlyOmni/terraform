# VPC outputs
output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "alb_frontend_dns" {
  value = module.alb_frontend.lb_dns_name
}

output "alb_backend_dns" {
  value = module.alb_backend.lb_dns_name
}

output "ecr_frontend_repo" {
  value = module.ecr.frontend_repository_url
}

output "ecr_backend_repo" {
  value = module.ecr.backend_repository_url
}

# CloudWatch & IAM & SSM outputs
output "cw_log_group_frontend" {
  value = module.cloudwatch_logs.frontend_log_group_name
}

output "cw_log_group_backend" {
  value = module.cloudwatch_logs.backend_log_group_name
}

output "ecs_execution_role_arn" {
  value = module.ecs_iam.execution_role_arn
}

output "ecs_task_role_arn" {
  value = module.ecs_iam.task_role_arn
}

output "ssm_frontend_api_param_arn" {
  value = module.ssm_parameters.frontend_param_arn
}

output "ssm_backend_db_connection_param_arn" {
  value     = module.ssm_parameters.backend_connection_param_arn
  sensitive = true
}

output "sg_alb_frontend_security_group_id" {
  value = module.security.alb_frontend_sg_id
}



output "cloudfront_distribution_domain_name" {
  value = module.cloudfront.distribution_domain_name
}



output "ecs_frontend_cluster_id" {
  value = module.ecs_frontend.cluster_id
}

output "ecs_frontend_service_name" {
  value = module.ecs_frontend.service_name
}

output "ecs_frontend_task_definition_arn" {
  value = module.ecs_frontend.task_definition_arn
}


output "ecs_backend_cluster_id" {
  value = module.ecs_backend.cluster_id
}

output "ecs_backend_service_name" {
  value = module.ecs_backend.service_name
}

output "ecs_backend_task_definition_arn" {
  value = module.ecs_backend.task_definition_arn
}
