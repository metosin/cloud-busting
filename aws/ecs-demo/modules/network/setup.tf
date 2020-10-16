provider "aws" {
  version = "3.11.0"
}

terraform {
  backend "s3" {
    key     = "network.tfstate"
    encrypt = true
  }
}
