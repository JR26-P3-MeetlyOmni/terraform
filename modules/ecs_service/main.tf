locals {
  environment_kv = merge({
    NODE_ENV = var.env
  }, var.environment_variables)

  environment_list = [
    for key, value in local.environment_kv : {
      name  = key
      value = value
    }
  ]

  secret_environment_list = [
    for key, value in var.secret_environment_variables : {
      name      = key
      valueFrom = value
    }
  ]

  log_stream_prefix = var.log_stream_prefix != "" ? var.log_stream_prefix : "ecs"

  firelens_cloudwatch_options = merge(
    {
      Name              = "cloudwatch"
      region            = var.log_group_region
      log_group_name    = var.log_group_name
      log_stream_prefix = var.firelens_log_stream_prefix != "" ? var.firelens_log_stream_prefix : var.container_name
      auto_create_group = var.firelens_auto_create_group ? "true" : "false"
    },
    var.firelens_log_options
  )

  firelens_log_configuration = {
    logDriver = "awsfirelens"
    options   = local.firelens_cloudwatch_options
  }

  awslogs_log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-region        = var.log_group_region
      awslogs-group         = var.log_group_name
      awslogs-stream-prefix = local.log_stream_prefix
    }
  }

  application_log_configuration = var.enable_firelens ? local.firelens_log_configuration : local.awslogs_log_configuration
  application_container_base = {
    name      = var.container_name
    image     = var.container_image
    essential = true
    portMappings = [
      {
        containerPort = var.container_port
        hostPort      = var.container_port
        protocol      = "tcp"
      }
    ]
    environment      = local.environment_list
    logConfiguration = local.application_log_configuration
  }

  application_container = merge(
    local.application_container_base,
    length(local.secret_environment_list) > 0 ? {
      secrets = local.secret_environment_list
    } : {},
    var.enable_firelens ? {
      dependsOn = [
        {
          containerName = var.firelens_container_name
          condition     = "START"
        }
      ]
    } : {}
  )
  firelens_container = var.enable_firelens ? [
    {
      name      = var.firelens_container_name
      image     = var.firelens_image
      essential = true
      firelensConfiguration = {
        type = "fluentbit"
        options = {
          "enable-ecs-log-metadata" = var.firelens_enable_ecs_log_metadata ? "true" : "false"
        }
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = var.log_group_region
          awslogs-group         = var.log_group_name
          awslogs-stream-prefix = "firelens"
        }
      }
    }
  ] : []

  adot_resource_attributes = [
    for key, value in var.adot_resource_attributes : "${key}=${value}"
  ]

  adot_environment_base = {
    AWS_REGION              = var.aws_region
    AWS_PROMETHEUS_ENDPOINT = var.adot_remote_write_endpoint
  }

  adot_environment_with_config = var.adot_config_content != "" ? merge(
    local.adot_environment_base,
    {
      AWS_OTEL_COLLECTOR_CONFIG_CONTENT = var.adot_config_content
    }
  ) : local.adot_environment_base

  adot_environment_with_attrs = length(local.adot_resource_attributes) > 0 ? merge(
    local.adot_environment_with_config,
    {
      OTEL_RESOURCE_ATTRIBUTES = join(",", local.adot_resource_attributes)
    }
  ) : local.adot_environment_with_config

  adot_environment_kv = merge(
    local.adot_environment_with_attrs,
    var.adot_environment_variables
  )

  adot_environment_list = [
    for key, value in local.adot_environment_kv : {
      name  = key
      value = value
    }
  ]

  adot_container = var.enable_adot_collector ? [
    {
      name        = var.adot_container_name
      image       = var.adot_container_image
      essential   = true
      environment = local.adot_environment_list
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = var.aws_region
          awslogs-group         = var.adot_log_group_name
          awslogs-stream-prefix = "collector"
        }
      }
      portMappings = var.adot_container_port_mappings
    }
  ] : []

  container_definitions = jsonencode(concat(
    [local.application_container],
    local.firelens_container,
    local.adot_container
  ))
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = local.container_definitions

  tags = var.tags
}

resource "aws_ecs_service" "this" {
  name                               = "${var.task_family}-svc"
  cluster                            = var.cluster_arn
  task_definition                    = aws_ecs_task_definition.this.arn
  desired_count                      = var.desired_count
  launch_type                        = "FARGATE"
  platform_version                   = var.platform_version
  enable_execute_command             = var.enable_execute_command
  propagate_tags                     = var.propagate_tags
  deployment_minimum_healthy_percent = var.deployment_min_healthy_percent
  deployment_maximum_percent         = var.deployment_max_percent

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  depends_on = [
    aws_ecs_task_definition.this
  ]

  tags = var.tags
}









