provider "aws" {
  region = var.region
}

module "ecr" {
  source = "./modules/ecr"

  name_prefix = var.name_prefix
  env         = var.env
}

module "network" {
  source      = "./modules/vpc"
  name_prefix = var.name_prefix

  env                    = var.env
  tags                   = var.tags
  vpc_name               = var.vpc_name
  vpc_cidr               = var.vpc_cidr
  vpc_azs                = var.vpc_azs
  public_subnets         = var.vpc_public_subnets
  private_subnets        = var.vpc_private_subnets
  enable_nat_gateway     = var.vpc_enable_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
}

module "ecs_iam" {
  source = "./modules/ecs_iam"

  name_prefix        = var.name_prefix
  env                = var.env
  ecs_execution_role = var.ecs_execution_role
  ecs_task_role      = var.ecs_task_role
}

module "ssm_parameters" {
  source = "./modules/ssm_parameters"

  name_prefix                  = var.name_prefix
  env                          = var.env
  frontend_api_base_url        = var.frontend_api_base_url
  backend_db_connection_string = var.backend_db_connection_string
}

module "security" {
  source      = "./modules/sg"
  name_prefix = var.name_prefix

  env                     = var.env
  tags                    = var.tags
  vpc_id                  = module.network.vpc_id
  alb_frontend            = var.alb_frontend
  alb_backend             = var.alb_backend
  sg_app_frontend         = var.sg_app_frontend
  sg_app_backend          = var.sg_app_backend
  frontend_container_port = var.frontend_container_port
  backend_container_port  = var.backend_container_port
  enable_https            = var.enable_https
}

module "alb_frontend" {
  source   = "./modules/alb"
  alb_name = "${var.name_prefix}-${var.alb_frontend}"

  tags                             = var.tags
  security_group_id                = module.security.alb_frontend_sg_id
  subnet_ids                       = module.network.public_subnet_ids
  target_group_name_prefix         = "fe-"
  target_group_port                = var.frontend_container_port
  target_group_protocol            = "HTTP"
  target_group_target_type         = "ip"
  health_check_path                = "/"
  health_check_matcher             = "200-399"
  health_check_interval            = 30
  health_check_timeout             = 5
  health_check_healthy_threshold   = 2
  health_check_unhealthy_threshold = 2
  enable_https                     = var.enable_https
  certificate_arn                  = var.acm_certificate_arn
}

module "alb_backend" {
  source   = "./modules/alb"
  alb_name = "${var.name_prefix}-${var.alb_backend}"

  tags                             = var.tags
  security_group_id                = module.security.alb_backend_sg_id
  subnet_ids                       = module.network.public_subnet_ids
  target_group_name_prefix         = "be-"
  target_group_port                = var.backend_container_port
  target_group_protocol            = "HTTP"
  target_group_target_type         = "ip"
  health_check_path                = "/health"
  health_check_matcher             = "200-399"
  health_check_interval            = 30
  health_check_timeout             = 5
  health_check_healthy_threshold   = 2
  health_check_unhealthy_threshold = 2
  enable_https                     = var.enable_https
  certificate_arn                  = var.acm_certificate_arn
}

module "cloudwatch_logs" {
  source = "./modules/cloudwatch"

  name_prefix       = var.name_prefix
  env               = var.env
  retention_in_days = var.logs_retention_days
}

module "ecs_frontend" {
  source = "./modules/ecs"

  env                            = var.env
  tags                           = var.tags
  cluster_name                   = "${var.name_prefix}-${var.env}-ecs-frontend"
  task_family                    = "${var.name_prefix}-${var.env}-frontend"
  execution_role_arn             = module.ecs_iam.execution_role_arn
  task_role_arn                  = module.ecs_iam.task_role_arn
  container_name                 = "frontend"
  container_image                = var.frontend_image
  container_port                 = var.frontend_container_port
  cpu                            = var.frontend_cpu != null ? tostring(var.frontend_cpu) : "256"
  memory                         = var.frontend_memory != null ? tostring(var.frontend_memory) : "512"
  desired_count                  = var.desired_count_frontend
  subnet_ids                     = module.network.private_subnet_ids
  security_group_ids             = [module.security.ecs_frontend_sg_id]
  target_group_arn               = module.alb_frontend.target_group_arn
  assign_public_ip               = false
  platform_version               = "1.4.0"
  enable_execute_command         = true
  log_group_name                 = module.cloudwatch_logs.frontend_log_group_name
  log_group_region               = var.region
  environment_variables          = {}
  propagate_tags                 = "SERVICE"
  deployment_min_healthy_percent = 50
  deployment_max_percent         = 200
}

module "ecs_backend" {
  source = "./modules/ecs"

  env                    = var.env
  tags                   = var.tags
  cluster_name           = "${var.name_prefix}-${var.env}-ecs-backend"
  task_family            = "${var.name_prefix}-${var.env}-backend"
  execution_role_arn     = module.ecs_iam.execution_role_arn
  task_role_arn          = module.ecs_iam.task_role_arn
  container_name         = "meetly-omni-backend"
  container_image        = var.backend_image
  container_port         = var.backend_container_port
  cpu                    = var.backend_cpu != null ? tostring(var.backend_cpu) : "512"
  memory                 = var.backend_memory != null ? tostring(var.backend_memory) : "1024"
  desired_count          = var.desired_count_backend
  subnet_ids             = module.network.private_subnet_ids
  security_group_ids     = [module.security.ecs_backend_sg_id]
  target_group_arn       = module.alb_backend.target_group_arn
  assign_public_ip       = false
  platform_version       = "1.4.0"
  enable_execute_command = true
  log_group_name         = module.cloudwatch_logs.backend_log_group_name
  log_group_region       = var.region
  environment_variables = {
    ASPNETCORE_ENVIRONMENT            = var.env
    ASPNETCORE_URLS                   = "http://0.0.0.0:${var.backend_container_port}"
    "ConnectionStrings__MeetlyOmniDb" = var.backend_db_connection_string
    "Jwt__Issuer"                     = var.backend_jwt_issuer
    "Jwt__Audience"                   = var.backend_jwt_audience
    JWT_SIGNING_KEY                   = var.backend_jwt_signing_key
  }
  propagate_tags                 = "SERVICE"
  deployment_min_healthy_percent = 50
  deployment_max_percent         = 200
}

module "cloudfront" {
  source = "./modules/cloudfront"

  enabled                = var.enable_cloudfront
  origin_domain_name     = var.cloudfront_origin_domain_name != "" ? var.cloudfront_origin_domain_name : module.alb_frontend.lb_dns_name
  aliases                = var.cloudfront_aliases
  acm_certificate_arn    = var.cloudfront_certificate_arn
  origin_protocol_policy = var.enable_https ? "https-only" : "http-only"
}





