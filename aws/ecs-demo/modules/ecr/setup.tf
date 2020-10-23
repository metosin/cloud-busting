provider "aws" {
  version = "3.11.0"
}

terraform {
  backend "s3" {
    key     = "ecs-demo-ecr.tfstate"
    encrypt = true
  }
}
