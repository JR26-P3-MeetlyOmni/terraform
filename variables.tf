#global variables
variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "meetlyomni"
}

variable "env" {
  description = "Define the environment"
  type        = string
  default     = "dev"
}

variable "tags" {
  type    = map(string)
  default = {}
}

#vpc&network variables
variable "region" {
  description = "The region to deploy the infrastructure"
  type        = string
  default     = "ap-southeast-2"
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "The availability zones of the VPC"
  type        = list(string)
  default     = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
}

variable "vpc_public_subnets" {
  description = "The public subnets of the VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_private_subnets" {
  description = "The private subnets of the VPC"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT gatway for VPC"
  type        = bool
  default     = true
}

variable "one_nat_gateway_per_az" {
  description = "one_nat_gateway_per_az"
  type        = bool
  default     = true
}

variable "vpc_tages" {
  description = "tags to apply to resources created by vpc module"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
}

#cloudwatch log group
variable "logs_retention_days" {
  type        = number
  default     = 30
  description = "CloudWatch Logs retention in days"
}

variable "enable_container_insights" {
  description = "Enable ECS CloudWatch Container Insights"
  type        = bool
  default     = true
}

variable "container_insights_log_retention_days" {
  description = "Retention in days for ECS Container Insights log groups"
  type        = number
  default     = 30
}

variable "amp_workspace_alias" {
  description = "Alias for the Amazon Managed Prometheus workspace"
  type        = string
  default     = ""
}

variable "enable_firelens" {
  description = "Enable FireLens log routing for ECS services"
  type        = bool
  default     = true
}

variable "enable_adot_collector" {
  description = "Deploy AWS Distro for OpenTelemetry collector sidecar in ECS services"
  type        = bool
  default     = true
}

variable "adot_log_retention_days" {
  description = "Retention in days for ADOT collector CloudWatch log group"
  type        = number
  default     = 30
}

variable "grafana_cloud_account_id" {
  description = "AWS account ID provided by Grafana Cloud for AMP access"
  type        = string
  default     = ""
}

variable "grafana_cloud_external_id" {
  description = "External ID Grafana Cloud uses when assuming the AMP access role"
  type        = string
  default     = ""
} # IAM role
variable "ecs_execution_role" {
  description = "ecs task execution role name"
  type        = string
  default     = "ecs-execution-role"
}

variable "ecs_task_role" {
  description = "ecs task role name"
  type        = string
  default     = "ecs-task-role"
}

variable "github_oidc_subjects" {
  description = "GitHub OIDC subjects (repo:org/repo:ref:refs/heads/branch) allowed to assume the CI/CD role"
  type        = list(string)
  default = [
    "repo:JR26-P3-MeetlyOmni/*:ref:refs/heads/main",
    "repo:JR26-P3-MeetlyOmni/*:ref:refs/heads/main-biaojin",
    "repo:JR26-P3-MeetlyOmni/*:environment:prod"
  ]
}

variable "ci_cd_kms_key_arns" {
  description = "KMS keys that the CI/CD role can use. Leave as [*] to allow all keys."
  type        = list(string)
  default     = ["*"]
}

#ssm parameter store
variable "frontend_api_base_url" {
  type        = string
  description = "Frontend calls this API base URL (e.g. https://api-uat.meetlyomni.com)"
}

variable "backend_db_connection_string" {
  type        = string
  description = "Backend database connection string"
  sensitive   = true
  default     = null
}
variable "backend_jwt_issuer" {
  type        = string
  description = "JWT issuer for backend API"
}

variable "backend_jwt_audience" {
  type        = string
  description = "JWT audience for backend API"
}

variable "backend_jwt_signing_key" {
  type        = string
  description = "Base64-encoded JWT signing key for backend API"
  sensitive   = true
}
variable "backend_aspnet_environment" {
  description = "ASPNETCORE_ENVIRONMENT value for backend ECS tasks"
  type        = string
  default     = "Production"
}
# sg
variable "sg_app_frontend" {
  description = "frontend application security group"
  type        = string
  default     = "sg-app-frontend"
}

variable "sg_app_backend" {
  description = "backend application security group"
  type        = string
  default     = "sg-app-backend"
}

#alb
variable "alb_frontend" {
  description = "frontend load balancer"
  type        = string
  default     = "alb-frontend"
}

variable "alb_backend" {
  description = "backend load balancer"
  type        = string
  default     = "alb-backend"
}

variable "enable_https" {
  description = "Enable HTTPS listeners on both ALBs"
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN (if enable_https = true)"
  type        = string
  default     = ""
}

#ECS service
variable "frontend_cpu" {
  description = "ecs service cpu"
  type        = string
  default     = "512"
}

variable "frontend_memory" {
  description = "ecs service cpu"
  type        = string
  default     = "1024"
}


variable "backend_cpu" {
  description = "backend ecs service cpu"
  type        = string
  default     = "512"
}

variable "backend_memory" {
  description = "backend ecs service memory"
  type        = string
  default     = "1024"
}
# ECR image URIs 
variable "frontend_image" {
  type = string
}
variable "backend_image" {
  type = string
}

# Container settings
variable "frontend_container_port" {
  type    = number
  default = 3000
}

variable "backend_container_port" {
  type    = number
  default = 80
}


variable "desired_count_frontend" {
  type    = number
  default = 1
}

variable "desired_count_backend" {
  type    = number
  default = 1
}


variable "enable_cloudfront" {
  description = "Create CloudFront distribution in front of the frontend ALB"
  type        = bool
  default     = false
}

variable "cloudfront_aliases" {
  description = "Custom domain names for the CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "cloudfront_certificate_arn" {
  description = "ACM certificate ARN (in us-east-1) for CloudFront aliases"
  type        = string
  default     = ""
}

variable "cloudfront_origin_domain_name" {
  description = "Custom domain for CloudFront origin (leave empty to use ALB DNS)"
  type        = string
  default     = ""
}

# RDS configuration
variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Initial allocated storage for RDS (GB)"
  type        = number
  default     = 20
}

variable "rds_storage_type" {
  description = "RDS storage type"
  type        = string
  default     = "gp2"
}

variable "rds_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.14"
}

variable "rds_database_name" {
  description = "Initial database name"
  type        = string
  default     = "meetlyomni"
}

variable "rds_master_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "dbadmin"
}

variable "rds_multi_az" {
  description = "Whether to enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "rds_backup_retention_period" {
  description = "Automated backup retention period in days"
  type        = number
  default     = 7
}

variable "rds_deletion_protection" {
  description = "Enable deletion protection for the RDS instance"
  type        = bool
  default     = true
}

variable "rds_skip_final_snapshot" {
  description = "Skip final snapshot on instance deletion"
  type        = bool
  default     = true
}

variable "rds_apply_immediately" {
  description = "Apply modifications immediately"
  type        = bool
  default     = false
}

variable "rds_iam_auth_enabled" {
  description = "Enable IAM authentication for PostgreSQL"
  type        = bool
  default     = true
}

variable "rds_additional_allowed_security_group_ids" {
  description = "Additional security group IDs allowed to access the RDS instance"
  type        = list(string)
  default     = []
}

variable "rds_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the RDS instance"
  type        = list(string)
  default     = []
}




variable "static_site_force_destroy" {
  description = "Allow force destroy of the static assets bucket."
  type        = bool
  default     = false
}









