locals {
  workspace_name = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  module_name      = "ecs"
  res_prefix    = "${var.prefix}${local.workspace_name}"
  default_tags     = {
    Resprefix = local.res_prefix
    Prefix    = var.prefix
    Workspace = terraform.workspace
    Module    = local.module_name
    Terraform = "true"
  }
}

# Cluster is a collection of compute resources that can run tasks and services (docker containers in the end)
resource "aws_ecs_cluster" "backend" {
  name = "${local.res_prefix}-backend"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(local.default_tags, {
    Name      = "${local.res_prefix}-backend"
  })
}

# Service will keep a desired amount of docker containers always running
# Service can also be attached to a load balancer for HTTP, TCP or UDP traffic
resource "aws_ecs_service" "backend" {
  name            = "${local.res_prefix}-backend"
  cluster         = aws_ecs_cluster.backend.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.desired_count

  # We run containers with the Fargate launch type. The other alternative is EC2, in which case we'd provision EC2
  # instances and attach them to the cluster.
  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "${local.res_prefix}-backend"
    container_port   = var.backend_port
  }

  network_configuration {
    # Fargate uses awspvc networking, we tell here into what subnets to attach the service
    subnets = data.terraform_remote_state.network.outputs.private_subnet_ids
    # Ditto for security groups
    security_groups = [aws_security_group.backend.id]
  }

  tags = merge(local.default_tags, {
    Name      = "${local.res_prefix}-ecs-service"
  })
}

# This is used to read the current region name
data "aws_region" "current" {}

# Task definition is a description of parameters given to docker daemon, in order to run a container
resource "aws_ecs_task_definition" "backend" {
  family                   = "${local.res_prefix}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  # This is the IAM role that the docker daemon will use, e.g. for pulling the image from ECR (AWS's own docker repository)
  execution_role_arn = aws_iam_role.backend-task-execution.arn
  # If the containers in the task definition need to access AWS services, we'd specify a role via task_role_arn.
  # task_role_arn = ...
  cpu                = var.backend_cpu
  memory             = var.backend_memory
  container_definitions = jsonencode(
    [
      {
        name        = "${local.res_prefix}-backend"
        image       = "${data.terraform_remote_state.ecr.outputs.backend_repository_url}:${var.image_tag}"
        cpu         = var.backend_cpu
        memory      = var.backend_memory
        mountPoints = []
        volumesFrom = []
        essential   = true
        portMappings = [
          {
            # This port is the same that the contained application also uses
            containerPort = var.backend_port
            protocol      = "tcp"
          }
        ]
        # With Fargate, we use awsvpc networking, which will reserve a ENI (Elastic Network Interface) and attach it to
        # our VPC
        networkMode = "awsvpc"
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.backend.name
            awslogs-region        = data.aws_region.current.name
            awslogs-stream-prefix = "${local.res_prefix}-backend"
          }
        },
        environment = [
          {
            name  = "PORT"
            value = "4000"
          },
          {
            name  = "IMAGE_TAG"
            value = var.image_tag
          },
          {
            name = "DB_HOST"
            value = data.terraform_remote_state.rds.outputs.rds_address
          },
          {
            name = "DB_PORT"
            value = tostring(data.terraform_remote_state.rds.outputs.rds_port)
          },
          {
            name = "DB_NAME"
            value = data.terraform_remote_state.rds.outputs.database_name
          },
          {
            name = "DB_USER"
            # Note that for actual production use, you would create a less privileged user into the DB instance
            value = data.terraform_remote_state.rds.outputs.master_user_name
          }
        ]
        secrets = [
          {
            name = "DB_PASSWORD"
            valueFrom = data.terraform_remote_state.rds.outputs.master_password_ssm_parameter_name
          }
        ]
      }
  ])

  tags = merge(local.default_tags, {
    Name      = "${local.res_prefix}-ecs-task-definition"
  })
}

# Well create a log group and specify how long to retain logs
resource "aws_cloudwatch_log_group" "backend" {
  name              = "${local.res_prefix}-backend"
  retention_in_days = 365

  tags = merge(local.default_tags, {
    Name      = "${local.res_prefix}-ecs-log-group"
  })
}

# This IAM role will be used by the docker daemon
resource "aws_iam_role" "backend-task-execution" {
  name = "${local.res_prefix}-backend-task-execution"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Service = "ecs-tasks.amazonaws.com"
          }
          Action = "sts:AssumeRole"
        }
      ]
  })

  tags = merge(local.default_tags, {
    Name      = "${local.res_prefix}-backend-task-execution"
  })
}

# The IAM role above will be allowed to pull docker image from ECR, and to create Cloudwatch log groups
# See: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
resource "aws_iam_role_policy_attachment" "backend" {
  role       = aws_iam_role.backend-task-execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# The DB instance password is encrypted with the default SSM service KMS key
# We lookup the key ARN via a data source
data "aws_kms_key" "default-ssm-key" {
  key_id = "alias/aws/ssm"
}

# We create a policy to allow the docker daemon to read the database password from an encrypted SSM parameter
resource "aws_iam_role_policy" "secrets-for-docker" {
  name = "${local.res_prefix}-container-secrets"
  role = aws_iam_role.backend-task-execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "ssm:GetParameters",
        "kms:Decrypt"
      ],
      Resource = [
        "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${data.terraform_remote_state.rds.outputs.master_password_ssm_parameter_name}",
        data.aws_kms_key.default-ssm-key.arn
      ]
      Effect = "Allow"
    }]
  })
}
