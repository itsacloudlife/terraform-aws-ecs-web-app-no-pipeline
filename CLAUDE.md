# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Terraform module (`terraform-aws-ecs-web-app-no-pipeline`) that provisions an ECS-based web application on AWS. It is a fork/variant of the Cloud Posse `terraform-aws-ecs-web-app` module with the CodePipeline functionality removed or commented out.

## Architecture

### Core Components

This module orchestrates several AWS resources and sub-modules:

1. **ECR Repository** (`module.ecr`): Optional ECR repository for container images (controlled by `ecr_create_enabled`)

2. **CloudWatch Logs** (`aws_cloudwatch_log_group.app`): Log group for container logs (controlled by `cloudwatch_log_group_enabled`)

3. **ALB Ingress** (`module.alb_ingress`): Application Load Balancer target group and listener rules with support for:
   - Authenticated and unauthenticated paths/hosts
   - Cognito or OIDC authentication
   - Custom health checks

4. **Container Definition** (`module.container_definition`): ECS container definition with support for:
   - Environment variables and secrets
   - Volume mounts and port mappings
   - Init containers with dependency conditions
   - Custom healthchecks

5. **ECS Service** (`module.ecs_alb_service_task`): ECS service and task definition with:
   - Support for both ALB and NLB load balancers
   - Fargate or EC2 launch types
   - Security groups and IAM roles
   - ECS Exec capability

6. **Autoscaling** (`module.ecs_cloudwatch_autoscaling`): CPU/memory-based autoscaling policies

7. **CloudWatch Alarms** (`module.ecs_cloudwatch_sns_alarms` and `module.alb_target_group_cloudwatch_sns_alarms`): Service and load balancer metric alarms

### Key Files

- **main.tf**: Primary resource definitions and module compositions
- **variables.tf**: Input variable declarations (~1000+ lines with extensive configuration options)
- **outputs.tf**: Module outputs for ECR, ALB, ECS service, task roles, alarms, etc.
- **extras.tf**: Custom IAM policy document for task permissions (SSM, ECR, CloudWatch Logs) with `additional_task_permissions` variable for extensibility
- **context.tf**: Cloud Posse label module integration for consistent resource naming

### Important Architecture Notes

- **Container Image Source**: Uses either ECR (when `use_ecr_image = true`) or external image registry (`container_image` variable)
- **Init Containers**: Supports init containers with dependency conditions (START, COMPLETE, SUCCESS, HEALTHY) via `var.init_containers`
- **Dual Load Balancer Support**: Can attach both ALB and NLB simultaneously (checks for `nlb_ingress_target_group_arn`)
- **Custom Task Permissions**: The `extras.tf` file extends base IAM permissions for tasks with SSM parameter access, ECR pulls, and CloudWatch Logs
- **Container Definition Override**: Can override entire container definition with `var.container_definition`

## Development Commands

### Terraform Operations

```bash
# Initialize and download providers/modules
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy resources
terraform destroy
```

### Testing

Examples are located in `examples/` directory:
- `complete/`: Full-featured example
- `with_cognito_authentication/`: Cognito authentication example
- `with_google_oidc_authentication/`: Google OIDC example
- `without_authentication/`: Public access example

## Current Branch Context

Working on branch: `kyocare`
Main branch: `master`

Recent changes include:
- Adding `target_group_protocol` variable for HTTPS support
- Making ECR optional via `ecr_create_enabled`

## Terraform Version Requirements

- Terraform: >= 0.13.0
- AWS Provider: >= 3.34

## Key Configuration Patterns

### Authentication Setup

The module supports three authentication modes via `authentication_type`:
- `""` (empty): No authentication
- `"COGNITO"`: AWS Cognito authentication
- `"OIDC"`: OpenID Connect authentication

### Load Balancer Configuration

Listener ARNs are passed via:
- `alb_ingress_unauthenticated_listener_arns`: For public access
- `alb_ingress_authenticated_listener_arns`: For protected endpoints

Path/host-based routing via:
- `alb_ingress_unauthenticated_paths` / `alb_ingress_unauthenticated_hosts`
- `alb_ingress_authenticated_paths` / `alb_ingress_authenticated_hosts`

### Task Permissions Extension

To add custom IAM permissions, use `additional_task_permissions` list variable. The base permissions in `extras.tf` already include SSM, ECR, and CloudWatch Logs access.
