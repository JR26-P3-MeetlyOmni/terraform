output "amp_workspace_id" {
  description = "ID of the AMP workspace"
  value       = aws_prometheus_workspace.this.id
}

output "amp_workspace_arn" {
  description = "ARN of the AMP workspace"
  value       = aws_prometheus_workspace.this.arn
}

output "amp_workspace_endpoint" {
  description = "Prometheus endpoint URL for the AMP workspace"
  value       = aws_prometheus_workspace.this.prometheus_endpoint
}

output "amp_remote_write_policy_arn" {
  description = "IAM policy ARN granting remote write access to the AMP workspace"
  value       = aws_iam_policy.amp_remote_write.arn
}

output "container_insights_performance_log_group" {
  description = "CloudWatch log group for Container Insights performance metrics"
  value       = aws_cloudwatch_log_group.container_insights_performance.name
}

output "container_insights_event_log_group" {
  description = "CloudWatch log group for Container Insights events"
  value       = aws_cloudwatch_log_group.container_insights_event.name
}

output "adot_collector_log_group" {
  description = "CloudWatch log group for ADOT collector logs"
  value       = aws_cloudwatch_log_group.adot_collector.name
}

output "grafana_amp_role_arn" {
  description = "IAM role ARN that Grafana Cloud can assume for AMP read access"
  value       = local.create_grafana_role ? aws_iam_role.grafana_amp_access[0].arn : null
}

output "grafana_amp_policy_arn" {
  description = "IAM policy ARN granting Grafana Cloud AMP query permissions"
  value       = local.create_grafana_role ? aws_iam_policy.grafana_amp_query[0].arn : null
}

