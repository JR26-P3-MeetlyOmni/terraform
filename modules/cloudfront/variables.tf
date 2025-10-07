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


variable "enable_asset_origin" {
  type    = bool
  default = false
}

variable "asset_origin_domain_name" {
  type    = string
  default = ""

  validation {
    condition     = !var.enable_asset_origin || length(trimspace(var.asset_origin_domain_name)) > 0
    error_message = "Provide asset_origin_domain_name when enable_asset_origin is true."
  }
}

variable "asset_origin_id" {
  type    = string
  default = "s3-asset-origin"
}

variable "asset_path_pattern" {
  type    = string
  default = "/StaticFiles/assets/images/*"
}

variable "asset_viewer_protocol_policy" {
  type    = string
  default = "redirect-to-https"
}

variable "asset_allowed_methods" {
  type    = list(string)
  default = ["GET", "HEAD"]
}

variable "asset_cached_methods" {
  type    = list(string)
  default = ["GET", "HEAD"]
}

variable "asset_compress" {
  type    = bool
  default = true
}

variable "asset_min_ttl" {
  type    = number
  default = 0
}

variable "asset_default_ttl" {
  type    = number
  default = 0
}

variable "asset_max_ttl" {
  type    = number
  default = 0
}

variable "asset_forward_query_string" {
  type    = bool
  default = false
}

variable "asset_cookie_forward" {
  type    = string
  default = "none"
}
