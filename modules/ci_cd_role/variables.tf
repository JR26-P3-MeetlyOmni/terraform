variable "name_prefix" {
  type = string
}

variable "env" {
  type = string
}

variable "role_suffix" {
  type    = string
  default = "ci-cd"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "github_oidc_subjects" {
  description = "List of GitHub OIDC subjects (repo:org/repo:ref:refs/heads/branch) allowed to assume the role."
  type        = list(string)
}

variable "ssm_parameter_prefix" {
  description = "Base path for SSM parameters the pipeline can read (e.g. /app/prod). Defaults to /{name_prefix}/{env}."
  type        = string
  default     = null
}

variable "kms_key_arns" {
  description = "KMS keys the pipeline can use for encrypt/decrypt operations."
  type        = list(string)
  default     = ["*"]
}

variable "ecr_repository_arns" {
  description = "Specific ECR repository ARNs the pipeline can push to. Defaults to all repositories in the account."
  type        = list(string)
  default     = []
}

variable "pass_role_arns" {
  description = "IAM role ARNs that the pipeline is allowed to pass to ECS (task and execution roles)."
  type        = list(string)
  default     = []
}
