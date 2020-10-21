locals {
  workspace_name = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  prefix_name = "${var.prefix}${local.workspace_name}"
}

resource "aws_ecs_cluster" "main" {
  name = "${local.prefix_name}-main"

  tags = {
    Name      = "${local.prefix_name}-main"
    Prefix    = var.prefix
    Workspace = terraform.workspace
  }
}
