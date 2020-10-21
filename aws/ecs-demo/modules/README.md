# Webapp modules

This example consists of the following modules:

* network: A VPC within which the backend and database are to be run
* ecs: Resources for running the webapp container and providing a load balancer endpoint to the application
* rds: A PostgreSQL database module

Your next step is to open terminal in each of these directories and give the following commands (just as you did previously with the backend):

* source ../../../tools/terraform-init
* terraform plan
* terraform apply

NOTE: We replace `terraform init` with our script here (`ource ../../../tools/terraform-init`) - the script populates the correct values for the Terraform state S3 bucket, lock DynamoDB table and the KMS encrytion key that you used when initializing the backend earlier.
