# Terraform Infrastructure

This repository now provisions the core MeetlyOmni infrastructure together with a full observability stack (Container Insights, FireLens, Amazon Managed Service for Prometheus, and Grafana Cloud integration helpers).

## Monitoring Highlights
- **CloudWatch Container Insights** is enabled for the ECS cluster with retention-controlled log groups for `/performance` and `/event` streams.
- **FireLens** routes application stdout/stderr through Fluent Bit so logs continue flowing into the service-specific CloudWatch log groups.
- **AWS Distro for OpenTelemetry (ADOT)** runs as a sidecar in every ECS service task and remote-writes ECS task metrics to AMP, using SigV4 authentication.
- **Amazon Managed Service for Prometheus (AMP)** workspace plus IAM policies are managed in the new `modules/monitoring` module.
- **Grafana Cloud** support includes an optional trust role and scoped query policy. Set the Grafana account and external ID when ready and use the exposed role ARN as the data source credential.

## Key Variables
All variables live in `variables.tf` and can be overridden per environment in `dev.tfvars`/`prod.tfvars`:
- `enable_firelens` / `enable_adot_collector` toggle the new sidecars (default: enabled).
- `container_insights_log_retention_days` / `adot_log_retention_days` Control CloudWatch retention for Container Insights and ADOT logs.
- `amp_workspace_alias` friendly alias for the AMP workspace (defaults to `<name>-<env>-amp`).
- `grafana_cloud_account_id` & `grafana_cloud_external_id` populate with values from Grafana Cloud to materialise the IAM trust role.
- `backend_db_connection_string` overrides the RDS endpoint; populate it when you need to source credentials from a third-party database (it is still written into SSM for CI/CD).

## Deploying
1. Update the appropriate `.tfvars` file with any environment specific values (Grafana IDs, retention overrides, etc.).
2. Run `terraform init` (first time or when modules/plugins change).
3. Apply with `terraform apply -var-file=<env>.tfvars`.
4. After apply, note the outputs:
   - `amp_workspace_endpoint` and `amp_remote_write_endpoint` for ADOT/Grafana configuration.
   - `amp_remote_write_policy_arn` (attached to ECS task role) and the optional `grafana_amp_role_arn` / `grafana_amp_policy_arn`.

## Grafana Cloud Integration
1. In Grafana Cloud > Connections > AWS, create a new AMP data source and copy the provided AWS account ID and external ID.
2. Set `grafana_cloud_account_id` / `grafana_cloud_external_id` in the relevant tfvars file.
3. Re-run `terraform apply` to create the trust role. Use the `grafana_amp_role_arn` output when configuring the Grafana data source (SigV4 authentication with the generated role).

## Post-Deployment Validation
- **ECS tasks**: `aws ecs describe-tasks` should show `aws-otel-collector` and `log_router` containers running alongside the service container.
- **CloudWatch Logs**: confirm new log groups exist `/aws/ecs/containerinsights/<cluster>/performance`, `/event`, and `/adot`.
- **AMP metrics**: use `aws amp list-workspaces` then `aws amp query-metrics --workspace-id <id> --query 'awsecs_container_memory_utilization'` (or view in Grafana) to verify ingestion.
- **ADOT logs**: check the ADOT log group for startup or authentication issues.
- **FireLens**: application log streams should now appear under the same CloudWatch groups with `frontend` / `backend` prefixes.

## Template Files
- `templates/adot-collector-config.yaml.tmpl` defines the collector pipeline (OTLP AMP). Modify if you need extra receivers/exporters.



