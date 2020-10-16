provider "aws" {
  version = "3.11.0"
}

terraform {
  backend "s3" {
    key     = "ecs.tfstate"
    encrypt = true
  }
}

data "terraform_remote_state" "network" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    key    = "network.tfstate"
    bucket = var.state_bucket
  }
}
