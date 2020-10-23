locals {
  workspace_name = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  prefix_name    = "${var.prefix}${local.workspace_name}"
}

resource "aws_ecr_repository" "backend" {
  name = "${local.prefix_name}-backend"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
