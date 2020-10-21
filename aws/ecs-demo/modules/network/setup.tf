provider "aws" {
  version = "3.11.0"
}

terraform {
  backend "s3" {
    key     = "ecs-demo-network.tfstate"
    encrypt = true
  }
}
