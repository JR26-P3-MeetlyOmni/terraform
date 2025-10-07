data "aws_iam_policy_document" "amp_remote_write" {
  statement {
    sid = "RemoteWriteWorkspace"
    actions = [
      "aps:RemoteWrite",
      "aps:DescribeWorkspace"
    ]
    resources = [aws_prometheus_workspace.this.arn]
  }

  statement {
    sid       = "ListWorkspaces"
    actions   = ["aps:ListWorkspaces"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "amp_remote_write" {
  name        = "${local.name_suffix}-amp-remote-write"
  description = "Allow ECS tasks to remote write metrics to AMP workspace"
  policy      = data.aws_iam_policy_document.amp_remote_write.json
}

data "aws_iam_policy_document" "grafana_assume" {
  count = local.create_grafana_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.grafana_cloud_account_id}:root"]
    }

    dynamic "condition" {
      for_each = trimspace(var.grafana_cloud_external_id) != "" ? [var.grafana_cloud_external_id] : []
      content {
        test     = "StringEquals"
        variable = "sts:ExternalId"
        values   = [condition.value]
      }
    }
  }
}

data "aws_iam_policy_document" "grafana_amp_query" {
  count = local.create_grafana_role ? 1 : 0

  statement {
    sid = "QueryWorkspace"
    actions = [
      "aps:QueryMetrics",
      "aps:GetSeries",
      "aps:GetLabels",
      "aps:GetMetricMetadata",
      "aps:DescribeWorkspace",
      "aps:DescribeAlertManagerConfiguration",
      "aps:DescribeRuleGroupsNamespace",
      "aps:ListRuleGroupsNamespaces"
    ]
    resources = [aws_prometheus_workspace.this.arn]
  }

  statement {
    sid       = "ListWorkspaces"
    actions   = ["aps:ListWorkspaces"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "grafana_amp_query" {
  count       = local.create_grafana_role ? 1 : 0
  name        = "${local.name_suffix}-amp-grafana-query"
  description = "Allow Grafana Cloud to query AMP workspace"
  policy      = data.aws_iam_policy_document.grafana_amp_query[count.index].json
}

resource "aws_iam_role" "grafana_amp_access" {
  count              = local.create_grafana_role ? 1 : 0
  name               = "${local.name_suffix}-grafana-amp"
  assume_role_policy = data.aws_iam_policy_document.grafana_assume[count.index].json
}

resource "aws_iam_role_policy_attachment" "grafana_amp_query" {
  count      = local.create_grafana_role ? 1 : 0
  role       = aws_iam_role.grafana_amp_access[count.index].name
  policy_arn = aws_iam_policy.grafana_amp_query[count.index].arn
}

