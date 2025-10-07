locals {
  name_suffix = "${var.name_prefix}-${var.env}"

  tags = merge(
    {
      Environment = var.env
    },
    var.tags
  )

  adot_log_retention  = coalesce(var.adot_log_retention_in_days, var.container_insights_log_retention_in_days)
  create_grafana_role = trimspace(var.grafana_cloud_account_id) != ""
}

