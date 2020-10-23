locals {
  workspace_name = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  prefix_name    = "${var.prefix}${local.workspace_name}"
}

# Cluster is a collection of compute resources that can run tasks and services (docker containers in the end)
resource "aws_ecs_cluster" "backend" {
  name = "${local.prefix_name}-backend"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name      = "${local.prefix_name}-backend"
    Prefix    = var.prefix
    Workspace = terraform.workspace
  }
}

# Service will keep a desired amount of docker containers always running
# Service can also be attached to a load balancer for HTTP, TCP or UDP traffic
resource "aws_ecs_service" "backend" {
  name            = "backend"
  cluster         = aws_ecs_cluster.backend.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 2

  # We run containers with the Fargate launch type. The other alternative is EC2, in which case we'd provision EC2
  # instances and attach them to the cluster.
  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = var.backend_port
  }

  network_configuration {
    # Fargate uses awspvc networking, we tell here into what subnets to attach the service
    subnets = data.terraform_remote_state.network.outputs.private_subnet_ids
    # Ditto for security groups
    security_groups = [aws_security_group.backend.id]
  }
}

# This is used to read the current region name
data "aws_region" "current" {}

# Task definition is a description of parameters given to docker daemon, in order to run a container
resource "aws_ecs_task_definition" "backend" {
  family                   = "backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  # This is the IAM role that the docker daemon will use, e.g. for pulling the image from ECR (AWS's own docker repository)
  execution_role_arn = aws_iam_role.backend.arn
  cpu                = var.backend_cpu
  memory             = var.backend_memory
  container_definitions = jsonencode(
    [
      {
        name        = "backend"
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
            awslogs-group  = aws_cloudwatch_log_group.backend.name
            awslogs-region = data.aws_region.current.name
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
          }
        ]
      }
  ])
}

# Well create a log group and specify how long to retain logs
resource "aws_cloudwatch_log_group" "backend" {
  name              = "backend"
  retention_in_days = 365
}

# This IAM role will be used by the docker daemon
resource "aws_iam_role" "backend" {
  name = "backend"
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
}

# The IAM role above will be allowed to pull docker image from ECR, and to create Cloudwatch log groups
# See: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
resource "aws_iam_role_policy_attachment" "backend" {
  role       = aws_iam_role.backend.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
