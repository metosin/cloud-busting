# Webapp modules

This example consists of the following modules:

* network: A VPC within which the backend and database are to be run
* ecs: Resources for running the webapp container and providing a load balancer endpoint to the application
* rds: A PostgreSQL database module

## General Usage

The example(s) use a common way of running Terraform, described in the following sections.

### Resource naming

Resources are named in a named in a way that allows multiple instances to co-exist in the same AWS account. A Terraform variable `prefix` is used to store a prefix for the resource name. Workspaces are also used for naming, but this is elaborated a bit later in the workspaces section.

Before running Terraform in a shell, use assing a value to the `prefix` variable via [TF_VAR_name](https://www.terraform.io/docs/commands/environment-variables.html#tf_var_name) convention:

    $ export TF_VAR_prefix=cbkimmo

This will make the value visible to all modules that have `prefix` variable definition.

### Running commands

Also specify the AWS region to use:

    # Set region to Ireland
    $ export AWS_DEFAULT_REGION=eu-west-1

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
