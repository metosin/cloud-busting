# AWS examples

Contains AWS infrastructure examples and tooling to help running Terraform modules that refer to other modules via [remote state](https://www.terraform.io/docs/providers/terraform/d/remote_state.html).

## tools

Contains helpers:

* tools/terraform-init: Helper for running `terraform init` in modules that refer to other modules via `data.terraform_remote_state`

## ecs-demo

A sample web application that runs in Elastic Container Service (ECS) via [Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html).

## AWS Profile

You have to create an AWS profile for yourself. Follow [AWS instructions](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) how to create an AWS profile.

From now on we assume that you use your AWS profile in each terraform and aws cli command. Example:

```bash
AWS_PROFILE=your-profile terraform apply
``` 

Where `your-profile` is your aws profile in your `~/.aws/credentials` file as described in the previous documentation.
 
Or you can export the profile so that you don't have to provide it in every terraform and aws cli command:

```bash
export AWS_PROFILE=your-profile
```
