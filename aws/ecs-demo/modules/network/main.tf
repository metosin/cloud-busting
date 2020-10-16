locals {
  suffix = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name      = "${var.prefix}-vpc${local.suffix}"
    Prefix    = var.prefix
    Workspace = terraform.workspace
  }
}
