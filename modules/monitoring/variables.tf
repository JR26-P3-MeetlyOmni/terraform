variable "name_prefix" {
  type = string
}

variable "env" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "amp_workspace_alias" {
  type        = string
  description = "Alias displayed for the AMP workspace"
}

variable "ecs_cluster_name" {
  type        = string
  description = "Name of the ECS cluster for Container Insights log groups"
}

variable "container_insights_log_retention_in_days" {
  type        = number
  default     = 30
  description = "Retention period (days) for Container Insights log groups"
}

variable "adot_log_retention_in_days" {
  type        = number
  default     = null
  description = "Retention in days for ADOT collector log group (defaults to Container Insights retention when null)"
}

variable "grafana_cloud_account_id" {
  type        = string
  default     = ""
  description = "AWS account ID provided by Grafana Cloud for IAM role assumption"
}

variable "grafana_cloud_external_id" {
  type        = string
  default     = ""
  description = "External ID used by Grafana Cloud when assuming the AMP access role"
}

