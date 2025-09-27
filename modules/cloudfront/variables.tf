variable "enabled" {
  type    = bool
  default = false
}

variable "origin_domain_name" {
  type = string
}

variable "origin_id" {
  type    = string
  default = "frontend-alb"
}

variable "aliases" {
  type    = list(string)
  default = []
}

variable "acm_certificate_arn" {
  type = string

  validation {
    condition     = !var.enabled || length(trimspace(var.acm_certificate_arn)) > 0
    error_message = "When CloudFront is enabled, provide a non-empty ACM certificate ARN."
  }
}

variable "price_class" {
  type    = string
  default = "PriceClass_100"
}

variable "viewer_protocol_policy" {
  type    = string
  default = "redirect-to-https"
}

variable "allowed_methods" {
  type    = list(string)
  default = ["GET", "HEAD", "OPTIONS"]
}

variable "cached_methods" {
  type    = list(string)
  default = ["GET", "HEAD"]
}

variable "forward_query_string" {
  type    = bool
  default = true
}

variable "cookie_forward" {
  type    = string
  default = "all"
}

variable "compress" {
  type    = bool
  default = true
}

variable "minimum_protocol_version" {
  type    = string
  default = "TLSv1.2_2019"
}

variable "origin_protocol_policy" {
  type    = string
  default = "https-only"
}

variable "comment" {
  type    = string
  default = "Frontend CloudFront distribution"
}

