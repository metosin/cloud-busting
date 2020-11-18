# AWS Examples

Contains AWS infrastructure examples.

## General Usage

The example(s) use a common way of running Terraform, described in the following sections. Note that the instructions provided here may seem a bit long but setting up aws cli, terraform state etc. is a one time task per project.

### Setting Environment Variables for AWS Profile and Region

You have to install AWS cli and create an AWS profile yourself. Follow instructions in [installing aws cli](README-installing-aws-cli.md]).

Copy paste file [aws-envs_template.sh](tools/aws-envs_template.sh) to file name `aws-envs.sh` and then change your own values in that file. 

### Terraform backend creation

Before creating resources, a store for the [Terraform state](https://www.terraform.io/docs/backends/index.html) needs to be created.

```bash
cd terraform-backend
```

See instructions in [terraform-backend](./terraform-backend/README.md).

### Run the Demonstrations

Now you can go to the demonstration directory and create the actual AWS infrastructure. E.g. go to directory [ecs-demo](ecs-demo) and read the [instructions](ecs-demo/README.md).

