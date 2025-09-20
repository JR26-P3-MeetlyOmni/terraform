# MeetlyOmni Backend Terraform Infrastructure

This Terraform project provisions the AWS infrastructure for the MeetlyOmni backend application, including VPC, ECS cluster, Fargate services, auto-scaling, and supporting resources.

## Project Overview

This infrastructure deploys a containerized backend application on AWS ECS Fargate with the following components:

- **VPC Networking**: Custom VPC with public and private subnets across multiple availability zones
- **ECS Cluster**: Container orchestration cluster for running the backend services
- **Fargate Services**: Serverless container deployment for the Meetly Omni backend
- **Application Load Balancer**: Distributes traffic to ECS tasks
- **Auto Scaling**: Automatic scaling of ECS tasks based on demand
- **State Management**: S3 backend with DynamoDB locking for Terraform state

## Architecture

For a detailed architecture diagram, refer to:
[Meetly Omni Architecture Diagram](https://viewer.diagrams.net/?tags=%7B%7D&lightbox=1&highlight=0000ff&layers=1&nav=1&title=meetlyomni-architecture-dev.drawio&dark=auto#Uhttps%3A%2F%2Fraw.githubusercontent.com%2Fgeekcu%2Fdesign-drawing%2Fmaster%2Fmeetlyomni-architecture-dev.drawio)

The architecture includes:
- VPC with public and private subnets across multiple availability zones
- Application Load Balancer distributing traffic to ECS tasks
- ECS Cluster running Fargate tasks with the Meetly Omni backend container
- Auto-scaling policies for optimal resource utilization
- Secure networking with appropriate security groups
- Terraform state management with S3 and DynamoDB

## Prerequisites

- AWS CLI configured with appropriate credentials
- AWS account with necessary permissions

## Configuration

### Variables

The main configuration variables are defined in `variables.tf`:

- `container_image`: ECR container image for the backend service
- `ecs_task_execution_role_arn`: IAM role for ECS task execution
- `connection_string`: Database connection string from AWS SSM Parameter Store
- `vpc_cidr_block`: CIDR block for the VPC (default: 10.0.0.0/16)
- `region`: AWS region (default: ap-southeast-2)
- `project`: Project name (default: meetlyomni)
- `environment`: Deployment environment (default: uat)
- `max_capacity`: Maximum ECS task count (default: 3)
- `min_capacity`: Minimum ECS task count (default: 1)

### Backend Configuration

Terraform state is stored in S3 with DynamoDB locking:
- S3 Bucket: `meetlyomni-tf-state-bucket-uat`
- DynamoDB Table: `terraform-state-locks-uat`
- Region: `ap-southeast-2`

## Modules

The infrastructure is organized into reusable modules:

### VPC Module (`modules/vpc/`)
- Creates VPC with public and private subnets
- Sets up route tables and internet gateway
- Configures security groups for ALB and ECS tasks
- Creates NAT gateway for private subnet internet access

### ECS Cluster Module (`modules/ecs-cluster/`)
- Creates ECS cluster for container orchestration
- Configures cluster logging and monitoring

### ECS Fargate Module (`modules/ecs-fargate/`)
- Defines ECS task definition with container specifications
- Creates ECS service with Fargate launch type
- Sets up Application Load Balancer and target groups
- Configures IAM roles and security groups

### Auto Scaling Module (`modules/auto-scaling/`)
- Configures application auto scaling for ECS service
- Sets scaling policies based on CPU utilization
- Manages desired task count within min/max limits

### Route53 Module (`modules/route53/`) - Pending
- DNS configuration for custom domain (currently commented out)

## Usage

### Initial Setup

1. **Backend Infrastructure** (one-time setup):
   ```bash
   cd backend-setup
   terraform init
   terraform plan
   terraform apply
   ```

2. **Main Infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Common Commands

```bash
# Initialize Terraform
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy

# View outputs
terraform output

# Refresh state
terraform refresh
```

## Outputs

The infrastructure provides the following outputs:

- VPC ID and subnet IDs
- ECS cluster ARN and name
- ALB DNS name and zone ID
- Security group IDs
- ECS service name

## Security

- VPC with isolated private subnets
- Security groups restricting traffic to necessary ports only
- Encrypted S3 bucket for Terraform state
- IAM roles with least privilege principles
- No public access to S3 state bucket

## Monitoring and Logging

- CloudWatch logs for ECS tasks
- ALB access logs
- Container insights for ECS cluster
- Auto-scaling based on CPU utilization metrics
