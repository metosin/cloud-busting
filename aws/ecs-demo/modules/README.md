# Webapp modules

This example consists of the following Terraform modules:

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
* common
  * Module for utility resources. Contains a SNS topic for monitoring use.
* dashboard
  * Creates a Cloudwatch Dashboard with metrics of the resources defined in other modules
  
Here's also picture of the module dependency graph:

![dependencies](./dependencies.png)

