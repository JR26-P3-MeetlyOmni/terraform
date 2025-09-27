variable "env" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "cluster_name" {
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
