variable "bucket_name" {
  description = "Name of the S3 bucket that stores the static assets."
  type        = string
}

variable "tags" {
  description = "Common resource tags to apply."
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "Whether to allow force destroy of the bucket."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable S3 bucket versioning."
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Default server-side encryption algorithm for S3 objects."
  type        = string
  default     = "AES256"
}

variable "kms_master_key_id" {
  description = "Optional KMS key ARN for S3 default encryption when using aws:kms."
  type        = string
  default     = ""
}

variable "price_class" {
  description = "CloudFront price class to use."
  type        = string
  default     = "PriceClass_100"
}

variable "comment" {
  description = "Optional comment for the CloudFront distribution."
  type        = string
  default     = ""
}

variable "aliases" {
  description = "Custom domain aliases for the CloudFront distribution."
  type        = list(string)
  default     = []
}

variable "default_root_object" {
  description = "Default root object served by CloudFront."
  type        = string
  default     = "index.html"
}

variable "viewer_protocol_policy" {
  description = "CloudFront viewer protocol policy."
  type        = string
  default     = "redirect-to-https"
}

variable "allowed_methods" {
  description = "Allowed HTTP methods for the default cache behavior."
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "cached_methods" {
  description = "Cached HTTP methods for the default cache behavior."
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "compress" {
  description = "Enable gzip/brotli compression for CloudFront."
  type        = bool
  default     = true
}

variable "min_ttl" {
  description = "Minimum TTL for CloudFront objects."
  type        = number
  default     = 0
}

variable "default_ttl" {
  description = "Default TTL for CloudFront objects."
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "Maximum TTL for CloudFront objects."
  type        = number
  default     = 86400
}

variable "forward_query_string" {
  description = "Whether CloudFront forwards query strings."
  type        = bool
  default     = false
}

variable "forward_headers" {
  description = "Which headers CloudFront forwards to the origin."
  type        = list(string)
  default     = []
}

variable "cookie_forward" {
  description = "How CloudFront handles cookies."
  type        = string
  default     = "none"
}

variable "query_string_cache_keys" {
  description = "Cache keys when forwarding query strings."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS support with custom domains."
  type        = string
  default     = ""
}

variable "minimum_protocol_version" {
  description = "Minimum TLS protocol version for CloudFront viewers."
  type        = string
  default     = "TLSv1.2_2021"
}

variable "is_ipv6_enabled" {
  description = "Enable IPv6 for the distribution."
  type        = bool
  default     = true
}

variable "wait_for_deployment" {
  description = "Whether Terraform should wait for the distribution to deploy."
  type        = bool
  default     = false
}

variable "web_acl_arn" {
  description = "Optional AWS WAF web ACL ARN to associate with CloudFront."
  type        = string
  default     = ""
}
