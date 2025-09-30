data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  account_id             = data.aws_caller_identity.current.account_id
  region                 = data.aws_region.current.id
  role_name              = "${var.name_prefix}-${var.env}-${var.role_suffix}"
  oidc_provider_arn      = "arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"
  parameter_prefix       = coalesce(var.ssm_parameter_prefix, "/${var.name_prefix}/${var.env}")
  parameter_prefix_clean = trim(local.parameter_prefix, "/")
  ssm_parameter_suffix   = local.parameter_prefix_clean == "" ? "*" : "${local.parameter_prefix_clean}/*"
  ssm_parameter_arn      = "arn:aws:ssm:${local.region}:${local.account_id}:parameter/${local.ssm_parameter_suffix}"
  ecr_repository_arns    = length(var.ecr_repository_arns) > 0 ? var.ecr_repository_arns : ["arn:aws:ecr:${local.region}:${local.account_id}:repository/*"]
  rds_resource_arns = [
    "arn:aws:rds:${local.region}:${local.account_id}:db:*",
    "arn:aws:rds:${local.region}:${local.account_id}:cluster:*"
  ]
  rds_db_connect_arn = "arn:aws:rds-db:${local.region}:${local.account_id}:dbuser:*/*"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = "GitHubActionsOIDC"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    dynamic "condition" {
      for_each = length(var.github_oidc_subjects) > 0 ? [1] : []
      content {
        test     = "StringLike"
        variable = "token.actions.githubusercontent.com:sub"
        values   = var.github_oidc_subjects
      }
    }
  }
}

resource "aws_iam_role" "this" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "ci_cd" {
  statement {
    sid = "AllowECRPushPull"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
      "ecr:ListImages",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]
    resources = local.ecr_repository_arns
  }

  statement {
    sid       = "AllowECRAuthToken"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid       = "AllowECSManagement"
    actions   = ["ecs:*"]
    resources = ["*"]
  }

  statement {
    sid = "AllowKMSUsage"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:DescribeKey"
    ]
    resources = var.kms_key_arns
  }

  statement {
    sid = "AllowSSMRead"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
      "ssm:DescribeParameters"
    ]
    resources = [local.ssm_parameter_arn]
  }

  statement {
    sid = "AllowRDSDescribeAndControl"
    actions = [
      "rds:Describe*",
      "rds:ListTagsForResource",
      "rds:AddTagsToResource",
      "rds:RemoveTagsFromResource",
      "rds:ModifyDBInstance",
      "rds:ModifyDBCluster",
      "rds:StartDBInstance",
      "rds:StopDBInstance",
      "rds:RebootDBInstance"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AllowRDSDbIAMAuth"
    actions   = ["rds-db:connect"]
    resources = [local.rds_db_connect_arn]
  }

  dynamic "statement" {
    for_each = length(var.pass_role_arns) > 0 ? [1] : []
    content {
      sid       = "AllowIamPassRole"
      actions   = ["iam:PassRole", "iam:GetRole"]
      resources = var.pass_role_arns
    }
  }
}

resource "aws_iam_policy" "ci_cd" {
  name   = "${local.role_name}-policy"
  policy = data.aws_iam_policy_document.ci_cd.json
}

resource "aws_iam_role_policy_attachment" "ci_cd" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ci_cd.arn
}

output "role_name" {
  value = aws_iam_role.this.name
}

output "role_arn" {
  value = aws_iam_role.this.arn
}

output "policy_arn" {
  value = aws_iam_policy.ci_cd.arn
}
