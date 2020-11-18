# Optional Reading

This document provides additional reading but is not mandatory to run the AWS demonstrations.


### Resource Naming

Resources are named in a way that allows multiple instances to co-exist in the same AWS account. A Terraform variable `prefix` is used to store a prefix for the resource name. Workspaces are also used for naming, but this is elaborated a bit later in the workspaces section.

We have made this part easier for you. You have already populated the `TF_VAR_prefix` environment variable in [aws-envs.sh](tools/aws-envs.sh) script and this script will automatically be called in each module.


### Do It Yourself or Use Terraform Registry

When implementing your own AWS infrastructure you should decide whether to do everything yourself using basic Terraform building blocks (e.g. as done in the ECS demonstration here) or using [Terraform Registry Modules](https://registry.terraform.io/browse/providers). Example. You can create an RDS either using the [Terraform Registry Module RDS](https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest) or building your RDS module yourself using [db_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) and other Terraform basic building blocks. In this example we have used the Terraform basic building blocks.

### One Mother Module or Independent Modules

You can create the Terraform solution many ways. One popular solution is to create one mother module in which you import dev/qa/prod values and inject these values to actual modules (e.g. network, rds...) that are imported to the mother module. This strategy makes the overall solution very simple: you can create the whole infrastructure using just one `terraform apply` command. The other side of the coin is that all resources are bundled in one Terraform state of the mother module.

Another solution is to create individual modules that each have their own state, which you can apply/destroy individually and use output variables to export parameters and read them via `terraform_remote_state` data source in other modules. This approach of linking modules via outputs/remote state corresponds to the ability of passing parameters from one module to another with a shared "mother" module. Also, when scale of the system grows large, stateful modules limit the amount of resources that need to be refreshed during apply/plan/destroy which yields better [performance](https://www.terraform.io/docs/state/purpose.html#performance), without need of disabling refresh. A module with state corresponds to a Stack in Cloudformation, see the [best practices of Cloudformation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/best-practices.html#organizingstacks) for ideas in designing stateful Terraform modules.

The latter strategy is used in the "ecs-demo" we have created in the "aws" directory. 

### Creating the Resources Individually

The resources of each module can be created by running the following commands inside the module directory:

* `source ../../../tools/terraform-init`
* `terraform plan`
* `terraform apply`

NOTE: We replace `terraform init` with our script here (`source ../../../tools/terraform-init`) - the script populates the correct values for the Terraform state S3 bucket, lock DynamoDB table and the KMS encrytion key that you used when initializing the backend earlier.

The modules depend on each other via [Terrafrom remote state](https://www.terraform.io/docs/providers/terraform/d/remote_state.html), so the [Terraform apply](https://www.terraform.io/docs/commands/apply.html) commands needs to be run in the module [dependency order](https://github.com/metosin/cloud-busting/blob/main/aws/ecs-demo/modules/README.md#module-dependencies).



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
## Production Considerations

The demos are simplified for brewity for educational purposes. In real productions systems you should consider the following options.


### Environment Specific Variable Files

In real projets, there would usually be separate environments (which can also be called stages), e.g. dev, test, qa, prod. The environments might preferrably reside in different AWS accounts, or even in the same AWS account (e.g. dev and test in one account, qa and prod separately).

The same Terraform configuration would be used for all of the environments, but usually parameterized, to minimize costs. For example, dev might use smaller instance sizes (EC2, RDS) while productions would use larger instances.

In Terraform, the parameterization can be done via input variables. Variable files can contain variable value assignments. It is customary to use a directory to hold the variable files for each environment. The environemnt specific variable file is then provided to the Terraform commands via the `-var-file` argument. In the ecs-demo, this setup is shown in the [ecs-demo/modules/network](ecs-demo/modules/network) module.

Using `dev` values:

```bash
terraform plan -var-file=vars/dev.tfvars
``` 

Using `prod` values:

```bash
terraform plan -var-file=vars/prod.tfvars
``` 

### Secrets

In Terraform, all resource attributes are stored into the Terraform backend state, including [sensetive data](https://www.terraform.io/docs/state/sensitive-data.html), for example the password of a master user of RDS/PostgreSQL instance. This is why the backend state file is encrypted at rest with a [KMS](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html) key.

With tools such as Ansible, it is common to use [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html) to store secrets into symmetrically encrypted files that are stored in version control (or encrypt specific variables by encrypting the variable string itself). Managing the access to the encryption key is then left to the project or operations team.

With Terraform, there isn't a single specific solution for this task. In this demo, we've chosen to use a tool by Mozilla called [Sops](https://github.com/mozilla/sops): Secrets OPerationS.

The `sops` tool takes a similar approach to Ansible Vault when encrypting string variables. The `sops` tool can be used to encrypt the **values** of JSON or YAML formatted data.

We use a Terraform provider, [terraform-provider-sops](https://github.com/carlpett/terraform-provider-sops) to integrate `sops` into Terraform. The provider is used to decrypt a file encrypted with `sops` and read values into Terraform resources.

This way, we can store an encrypted file into version control and decrypt the contents into use by Terraform.
