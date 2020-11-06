provider "aws" {
  version = "3.11.0"
}

terraform {
  backend "s3" {
    key     = "ecs-demo-rds.tfstate"
    encrypt = true
  }

  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "0.5.2"
    }
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
