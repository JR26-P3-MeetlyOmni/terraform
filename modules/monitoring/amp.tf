resource "aws_prometheus_workspace" "this" {
  alias = var.amp_workspace_alias

  tags = merge(local.tags, {
    Name = "${local.name_suffix}-amp"
  })
}

