# terraform-backend

Module for creating resources for [Terraform backend state](https://www.terraform.io/docs/backends/index.html) stored in S3, with concurrent operations prevented by a lock in DynamoDB table.

## Usage

First initialize the local backend:

```bash
terraform init
# You will see output like:
Initializing the backend...

Initializing provider plugins...
- Using previously-installed hashicorp/aws v3.11.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Check plan with:

```bash
terraform plan
# You will see output like:
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.
------------------------------------------------------------------------
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
Terraform will perform the following actions:
  # aws_dynamodb_table.terraform will be created
  + resource "aws_dynamodb_table" "terraform" {
      + arn              = (known after apply)
...
Plan: 6 to add, 0 to change, 0 to destroy.
```

Apply changes:

```bash
terraform apply
# You will see output like:
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
Terraform will perform the following actions:
...
```

Finally Terraform asks whether to apply the changes, reply: `yes`.

Terraform start to create the resources, you will see output like:

```
aws_kms_key.terraform: Creating...
aws_dynamodb_table.terraform: Creating...
aws_s3_bucket.terraform: Creating...
...
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
...
Outputs:
dynamodb_table = <PREFIX-YOU-USED>-terraform
kms_key_id = arn:aws:kms:eu-west-1:<SOME-STRING>
state_bucket = <PREFIX-YOU-USED>-terraform
```

At last, commit `terraform.tfstate` file, which is is local backend state file, into version control, so that the bootstrap state is persisted off your computer.
