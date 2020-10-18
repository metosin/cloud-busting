locals {
  suffix = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
}

resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-main${local.suffix}"

  tags = {
    Name      = "${var.prefix}-vpc${local.suffix}"
    Prefix    = var.prefix
    Workspace = terraform.workspace
  }
}
