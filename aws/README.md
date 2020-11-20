# AWS Examples

Contains AWS infrastructure examples.

## General Usage

The example(s) use a common way of running Terraform, described in the following sections. Note that the instructions provided here may seem a bit long but setting up aws cli, terraform state etc. is a one time task per project.

### Setting Environment Variables for AWS Profile and Region

You have to install AWS cli and create an AWS profile yourself. Follow instructions in [installing aws cli](README-installing-aws-cli.md).

Copy paste file [aws-envs_template.sh](tools/aws-envs_template.sh) to file name `aws-envs.sh` (in the same directory) and then change your own values in that file. 

### Terraform Backend Creation

Before creating resources, a store for the [Terraform state](https://www.terraform.io/docs/backends/index.html) needs to be created.

```bash
cd terraform-backend
```

See instructions in [terraform-backend](./terraform-backend/README.md).

### Run the Demonstrations

Now you can go to the demonstration directory and create the actual AWS infrastructure. Change working directory to ecs-demo and read the [instructions](ecs-demo/README.md).

### Further Reading

The [Optional Reading](optional-reading.md) document contains more in-depth discussion on the topics that are not covered by the simplified instructions to run the demonstrations. Also, check do check the Terraform source code in the examples. The resource definitions contain comments which explain briefly what the definitions are and what they mean.
