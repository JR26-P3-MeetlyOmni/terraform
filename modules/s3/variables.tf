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
