locals {
  execution_policy_map = { for idx, policy in var.execution_additional_policy_arns : tostring(idx) => policy }
  task_policy_map      = { for idx, policy in var.task_additional_policy_arns : tostring(idx) => policy }
}
data "aws_iam_policy_document" "ecs_tasks_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name               = "${var.name_prefix}-${var.env}-${var.ecs_execution_role}"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_trust.json
}

resource "aws_iam_role_policy_attachment" "execution_managed" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_region" "current" {}

data "aws_iam_policy_document" "execution_extra" {
  statement {
    sid = "ReadProjectSSMParams"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "arn:aws:ssm:*:*:parameter/${var.name_prefix}/*"
    ]
  }

  statement {
    sid       = "KMSDecryptForSSM"
    actions   = ["kms:Decrypt"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ssm.${data.aws_region.current.id}.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "execution_extra" {
  name   = "${var.name_prefix}-${var.env}-${var.ecs_execution_role}"
  policy = data.aws_iam_policy_document.execution_extra.json
}

resource "aws_iam_role_policy_attachment" "execution_extra_attach" {
  role       = aws_iam_role.execution.name
  policy_arn = aws_iam_policy.execution_extra.arn
}

resource "aws_iam_role" "task" {
  name               = "${var.name_prefix}-${var.env}-${var.ecs_task_role}"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_trust.json
}

resource "aws_iam_role_policy_attachment" "execution_additional" {
  for_each = local.execution_policy_map

  role       = aws_iam_role.execution.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "task_additional" {
  for_each = local.task_policy_map

  role       = aws_iam_role.task.name
  policy_arn = each.value
}




