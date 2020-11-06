# Webapp modules

This example consists of the following modules:

* network
  * A VPC within which the backend and database are to be run
* ecs
  * Resources for running the webapp container and providing a load balancer endpoint to the application
* rds
  * A PostgreSQL database module
* bastion
  * A bastion host for SSH tunneling
* ecr
  * A module for the Docker repository
* resource-groups
  * A module that defines resource groups for making it easier to find the resources from the AWS console

## Apply

Your next step is to open a terminal and `cd` into each of these directories and give the following commands (just as you did previously with the backend):

* `source ../../../tools/terraform-init`
* `terraform plan`
* `terraform apply`

NOTE: We replace `terraform init` with our script here (`source ../../../tools/terraform-init`) - the script populates the correct values for the Terraform state S3 bucket, lock DynamoDB table and the KMS encrytion key that you used when initializing the backend earlier.

The modules depend on each other via [Terrafrom remote state](https://www.terraform.io/docs/providers/terraform/d/remote_state.html), so the [Terraform apply](https://www.terraform.io/docs/commands/apply.html) commands needs to be run in the module dependency order:

```
network
ecr
rds
ecs
bastion
resource-groups
```

Here's also picture of the module dependency graph:

![dependencies](./dependencies.png)

# Destroy

For demo purposes, the `destroy-all.sh` script can be used to destroy all modules in one go, since it's a bit tedious to try remember to run destroy command in dependency order manually.
