resource "aws_cloudwatch_log_group" "container_insights_performance" {
  name              = "/aws/ecs/containerinsights/${var.ecs_cluster_name}/performance"
  retention_in_days = var.container_insights_log_retention_in_days
  tags              = local.tags
}

resource "aws_cloudwatch_log_group" "container_insights_event" {
  name              = "/aws/ecs/containerinsights/${var.ecs_cluster_name}/event"
  retention_in_days = var.container_insights_log_retention_in_days
  tags              = local.tags
}

resource "aws_cloudwatch_log_group" "adot_collector" {
  name              = "/aws/ecs/containerinsights/${var.ecs_cluster_name}/adot"
  retention_in_days = local.adot_log_retention
  tags              = local.tags
}

