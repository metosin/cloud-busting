# AWS examples

Contains AWS infrastructure examples.

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

```bash
export TF_VAR_prefix=cbkimmo
```

This will make the value visible to all modules that have `prefix` variable definition.

We have made this part easier for you. Populate your own values in [aws-envs.sh](tools/aws-envs.sh) script and call it in each module you are using:

```bash
source aws-envs.sh
```

### Terraform backend initialization

Before creating resources, a store for the [Terraform state](https://www.terraform.io/docs/backends/index.html) needs to be created.

```bash
cd terraform-backend
```

See instructions in [terraform-backend](./terraform-backend/README.md).

### Running Commands in Modules

Change the working directory into a module directory:

```bash
cd ecs-demo/modules/network
```

First, initialize the Terraform backend of a module with:

```bash
source ../../../tools/terraform-init
# You will see the following output:
Initializing the backend...
Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.
Initializing provider plugins...
- Finding hashicorp/aws versions matching "3.11.0"...
- Installing hashicorp/aws v3.11.0...
- Installed hashicorp/aws v3.11.0 (signed by HashiCorp)
Terraform has been successfully initialized!
...
```

After backend initialization, other Terraform commands can be run, for example, check the plan:

```bash
terrafrom plan
```

And apply changes:

```bash
terraform apply
```

### Usage with workspaces

[Terraform workspaces](https://www.terraform.io/docs/state/workspaces.html) can be used to create independent instances
of the resources defined in the modules. This is useful for example for demoing feature branches in such a way that they
do not collide with existing environment.

The example(s) use resource naming convention, where workspace name is added after the prefix, but before resource name, e.g.:

```
<prefix>-<workspace-name>-<resource-name>
```

If the `default` workspace is used, then the middle part is left out of resource name:

```
<prefix>-<resource-name>
```

To create a new workspace in a module, run

```bash
$ terraform workspace new experiment
Created and switched to workspace "experiment"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
```

Then run other Terraform commands normally. To see a list of workspaces, run:

```bash
$ terraform workspace list
default
* experiment
```

After the experiment is done, destroy infrastructure with `destroy` command.

```bash
terraform destroy
```

To return to default workspace, run:

```bash
terraform workspace select default
Switched to workspace "default".
```

## Directory listing

## tools

Contains helpers:

* tools/terraform-init: Helper for running `terraform init` in modules that refer to other modules via `data.terraform_remote_state`

## ecs-demo

A sample web application that runs in Elastic Container Service (ECS) via [Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html).

## Production Considerations

The demos are simplified for brewity for educational purposes. In real productions systems you should consider the following options.

- Bastion or Parameter Store solution: short explanation

### Vars files.

- Vars files for various environments, e.g. dev-vars.tf, qa-vars.tf. In real world projects you should be able to inject e.g. various instance sizes. TODO: selitä tässä, esimerkki network modulin vars-hakemistossa

Examples in the network module:

Using `dev` values:

```bash
terraform plan -var-file=vars/dev.tfvars
``` 

Using `prod` values:

```bash
terraform plan -var-file=vars/prod.tfvars
``` 

### Bastion Host or AWS TODO

- Bastion or Parameter Store solution: short explanation

### Secrets

- Secrets management. TODO: Kimmo.  TODO. vaihtoehdot: AWS Secrets Manager, TODO: Kimmon ratkaisu: tapa, miten työnnetään salaisuus SecretsManageriin..., lyhyt selitys niistä


### Do It Yourself or Use Terraform Registry

You should decide whether to do everything yourself using basic Terraform building blocks (e.g. ) or using [Terraform Registry Modules](https://registry.terraform.io/browse/providers). Example. You can create an RDS either using the [Terraform Registry Module RDS](https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest) or building your RDS module yourself using [db_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) and other Terraform basic building blocks. In this example we have used the Terraform basic building blocks.

### One Mother Module or Independent Modules

You can create the Terraform solution many ways. One popular solution is to create one mother module in which you import dev/qa/prod values and inject these values to actual modules (e.g. network, rds...) that are imported to the mother module. This strategy makes the overall solution very simple: you can create the whole infrastructure using just one `terraform apply` command. The other side of the coin is that all resources are bundled in one Terraform state of the mother module.

Another solution is to create individual modules that each have their own state, which you can apply/destroy individually and use output variables to export parameters and read them via `terraform_remote_state` data source in other modules. This approach of linking modules via outputs/remote state corresponds to the ability of passing parameters from one module to another with a shared "mother" module. Also, when scale of the system grows large, stateful modules limit the amount of resources that need to be refreshed during apply/plan/destroy which yields better [performance](https://www.terraform.io/docs/state/purpose.html#performance), without need of disabling refresh. A module with state corresponds to a Stack in Cloudformation, see the [best practices of Cloudformation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/best-practices.html#organizingstacks) for ideas in designing stateful Terraform modules.

The latter strategy is used in the "ecs-demo" we have created in the "aws" directory. 


  
