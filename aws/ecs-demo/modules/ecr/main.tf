locals {
  workspace_name = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  module_name      = "ecr"
  res_prefix    = "${var.prefix}${local.workspace_name}"
  default_tags     = {
    Resprefix = local.res_prefix
    Prefix    = var.prefix
    Workspace = terraform.workspace
    Module    = local.module_name
    Terraform = "true"
  }
}

resource "aws_ecr_repository" "backend" {
  name = "${local.res_prefix}-backend"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.default_tags, {
    Name = "${local.res_prefix}-backend"
  })

}
