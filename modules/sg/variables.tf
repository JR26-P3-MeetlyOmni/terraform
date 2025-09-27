variable "name_prefix" {
  type = string
}

variable "env" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vpc_id" {
  type = string
}

variable "alb_frontend" {
  type = string
}

variable "alb_backend" {
  type = string
}

variable "sg_app_frontend" {
  type = string
}

variable "sg_app_backend" {
  type = string
}

variable "frontend_container_port" {
  type = number
}

variable "backend_container_port" {
  type = number
}

variable "enable_https" {
  type = bool
}
