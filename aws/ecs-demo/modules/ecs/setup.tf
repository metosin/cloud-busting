provider "aws" {
  version = "3.11.0"
}

terraform {
  backend "s3" {
    key     = "ecs-demo-ecs.tfstate"
    encrypt = true
  }
}

data "terraform_remote_state" "network" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    key    = "ecs-demo-network.tfstate"
    bucket = var.state_bucket
  }
}

data "terraform_remote_state" "ecr" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    key    = "ecs-demo-ecr.tfstate"
    bucket = var.state_bucket
  }
}
