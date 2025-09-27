variable "alb_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "security_group_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "target_group_name_prefix" {
  type = string
}

variable "target_group_port" {
  type = number
}

variable "target_group_protocol" {
  type    = string
  default = "HTTP"
}

variable "target_group_target_type" {
  type    = string
  default = "ip"
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "health_check_matcher" {
  type    = string
  default = "200-399"
}

variable "health_check_interval" {
  type    = number
  default = 30
}

variable "health_check_timeout" {
  type    = number
  default = 5
}

variable "health_check_healthy_threshold" {
  type    = number
  default = 2
}

variable "health_check_unhealthy_threshold" {
  type    = number
  default = 2
}

variable "enable_https" {
  type = bool
}

variable "certificate_arn" {
  type    = string
  default = ""
}

