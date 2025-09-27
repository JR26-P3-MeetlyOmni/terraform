variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "env" {
  description = "Deployment environment"
  type        = string
}

variable "retention_in_days" {
  description = "CloudWatch Logs retention period"
  type        = number
}

variable "log_group_prefix" {
  description = "Base prefix for log group names"
  type        = string
  default     = "/ecs"
}

variable "frontend_log_group_suffix" {
  description = "Suffix for the frontend log group"
  type        = string
  default     = "frontend"
}

variable "backend_log_group_suffix" {
  description = "Suffix for the backend log group"
  type        = string
  default     = "backend"
}
