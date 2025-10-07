variable "env" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "cluster_arn" {
  type = string
}

variable "task_family" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "container_name" {
  type = string
}

variable "container_image" {
  type = string
}

variable "container_port" {
  type = number
}

variable "cpu" {
  type = string
}

variable "memory" {
  type = string
}

variable "desired_count" {
  type = number
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "assign_public_ip" {
  type    = bool
  default = true
}

variable "platform_version" {
  type    = string
  default = "1.4.0"
}

variable "enable_execute_command" {
  type    = bool
  default = true
}

variable "log_group_name" {
  type = string
}

variable "log_group_region" {
  type = string
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "propagate_tags" {
  type    = string
  default = "SERVICE"
}

variable "deployment_min_healthy_percent" {
  type    = number
  default = 50
}

variable "deployment_max_percent" {
  type    = number
  default = 200
}

variable "log_stream_prefix" {
  type    = string
  default = "ecs"
}

variable "enable_firelens" {
  type    = bool
  default = false
}

variable "firelens_container_name" {
  type    = string
  default = "log_router"
}

variable "firelens_image" {
  type    = string
  default = "public.ecr.aws/aws-observability/aws-for-fluent-bit:latest"
}

variable "firelens_log_stream_prefix" {
  type    = string
  default = ""
}

variable "firelens_log_options" {
  type    = map(string)
  default = {}
}

variable "firelens_enable_ecs_log_metadata" {
  type    = bool
  default = true
}

variable "firelens_auto_create_group" {
  type    = bool
  default = false
}

variable "aws_region" {
  type = string
}

variable "enable_adot_collector" {
  type    = bool
  default = false
}

variable "adot_container_name" {
  type    = string
  default = "aws-otel-collector"
}

variable "adot_container_image" {
  type    = string
  default = "public.ecr.aws/aws-observability/aws-otel-collector:latest"
}

variable "adot_remote_write_endpoint" {
  type    = string
  default = ""
}

variable "adot_config_content" {
  type    = string
  default = ""
}

variable "adot_log_group_name" {
  type    = string
  default = ""
}

variable "adot_environment_variables" {
  type    = map(string)
  default = {}
}

variable "adot_resource_attributes" {
  type    = map(string)
  default = {}
}

variable "adot_container_port_mappings" {
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))
  default = []
}

variable "secret_environment_variables" {
  type    = map(string)
  default = {}
}
