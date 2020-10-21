# AWS examples

Contains AWS infrastructure examples and tooling to help running Terraform modules that refer to other modules via [remote state](https://www.terraform.io/docs/providers/terraform/d/remote_state.html).

## tools

Contains helpers:

* tools/terraform-init: Helper for running `terraform init` in modules that refer to other modules via `data.terraform_remote_state`

## ecs-demo

A sample web application that runs in Elastic Container Service (ECS) via [Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html).

## General Usage

The example(s) use a common way of running Terraform, described in the following sections.

### AWS Profile and Region

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

Also specify the AWS region to use (eu-west-1 is Ireland):

```bash
export AWS_DEFAULT_REGION=eu-west-1
```

### Resource Naming

Resources are named in a way that allows multiple instances to co-exist in the same AWS account. A Terraform variable `prefix` is used to store a prefix for the resource name. Workspaces are also used for naming, but this is elaborated a bit later in the workspaces section.

Before running Terraform in a shell, assign a value to the `prefix` variable via [TF_VAR_name](https://www.terraform.io/docs/commands/environment-variables.html#tf_var_name) convention:

    $ export TF_VAR_prefix=cbkimmo

This will make the value visible to all modules that have `prefix` variable definition.

### Terraform backend initialization

Before creating resources, a store for the [Terraform state](https://www.terraform.io/docs/backends/index.html) needs to be created.

See instructions in [terraform-backend](./terraform-backend/README.md).

### Running Commands in Modules

Change the working directory into a module directory:

    $ cd ecs-demo/modules/network

First, initialize the Terraform backend of a module with:

    $ source ../../../tools/terraform-init

    Initializing the backend...

    Successfully configured the backend "s3"! Terraform will automatically
    use this backend unless the backend configuration changes.

    Initializing provider plugins...
    - Finding hashicorp/aws versions matching "3.11.0"...
    - Installing hashicorp/aws v3.11.0...
    - Installed hashicorp/aws v3.11.0 (signed by HashiCorp)

    Terraform has been successfully initialized!

    You may now begin working with Terraform. Try running "terraform plan" to see
    any changes that are required for your infrastructure. All Terraform commands
    should now work.

    If you ever set or change modules or backend configuration for Terraform,
    rerun this command to reinitialize your working directory. If you forget, other
    commands will detect it and remind you to do so if necessary.

After backend initialization, other Terraform commands can be run, for example, check the plan via

    $ terrafrom plan

And apply changes via

    $ terraform apply

### Usage with workspaces

[Terraform workspaces](https://www.terraform.io/docs/state/workspaces.html) can be used to create independent instances
of the resources defined in the modules. This is useful for example for demoing feature branches in such a way that they
do not collide with existing environment.

To create a new workspace in a module, run

    $ terraform workspace new experiment
    Created and switched to workspace "experiment"!

    You're now on a new, empty workspace. Workspaces isolate their state,
    so if you run "terraform plan" Terraform will not see any existing state
    for this configuration.

Then run other Terraform commands normally. To see a list of workspaces, run:

    $ terraform workspace list
    default
    * experiment

After the experiment is done, destroy infrastructure with `destroy` command.

    $ terraform destroy

To return to default workspace, run:

    $ terraform workspace select default
    Switched to workspace "default".
