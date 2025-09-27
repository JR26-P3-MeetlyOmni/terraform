variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "env" {
  description = "Deployment environment"
  type        = string
}

variable "frontend_repository_suffix" {
  description = "Suffix for the frontend repository name"
  type        = string
  default     = "frontend"
}

variable "backend_repository_suffix" {
  description = "Suffix for the backend repository name"
  type        = string
  default     = "backend"
}

variable "image_tag_mutability" {
  description = "ECR image tag mutability setting"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}
