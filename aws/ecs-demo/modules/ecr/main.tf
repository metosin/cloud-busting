locals {
  workspace_name = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  module_name      = "bastion"
  default_tags     = {
    Prefix    = var.prefix
    Workspace = terraform.workspace
    Module    = local.module_name
    Terraform = "true"
  }
}

resource "aws_ecr_repository" "backend" {
  name = "${var.prefix}${local.workspace_name}-backend"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.default_tags, {
    Name = "${var.prefix}${local.workspace_name}-backend"
  })

}
