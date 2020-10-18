# AWS examples

Contains AWS infrastructure examples and tooling to help running Terraform modules that refer to other modules via [remote state](https://www.terraform.io/docs/providers/terraform/d/remote_state.html).

## [Tooling](./tooling)

Contains helpers:

* [tools/terraform-init](./tools/terraform-init): Helper for running `terraform init` in modules that refer to other modules via `data.terraform_remote_state`

## [ECS demo](./ecs-demo)

A sample web application that runs in Elastic Container Service (ECS) via [Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html).
