# Resource Groups

This module provides a way to create virtual resource groups for easy discovery of the resources in the AWS Console.

## What are AWS Resource Groups

[AWS Resource Groups](https://docs.aws.amazon.com/ARG/latest/userguide/welcome.html) are a way to organize your AWS resources. Microsoft Azure provides a concept of a physical resource group, and GCP provides a concept of a Project - when you create your Azure resources in an Azure Resource Group and you create your GCP resources in a GCP Project - the Azure Resource Group and the GCP Project physically own the resources: i.e. when you destroy the Azure Resource Group or the GCP Project all the resources belonging to that Azure Resource Group or GCP Project are also destroyed. There is no physical resource group concept in AWS which is a bit of a pity since there is no easy way to know which resources belong to a certain system or project. One way to categorize AWS resources is tagging. You can and you should create a tagging scheme which you use in a coherent way to tag your AWS resources (read more about tagging in [Tagging Best Practices](https://d1.awsstatic.com/whitepapers/aws-tagging-best-practices.pdf) AWS paper).

## Tagging

We have used a coherent tagging scheme in this demonstration. All modules provide the default tags in the locals section, example:

```hcl-terraform
  default_tags = {
    Resprefix = local.res_prefix
    Prefix    = var.prefix
    Workspace = terraform.workspace
    Module    = local.module_name
    Terraform = "true"
  }
```   

Then various resources use these tags and provide their own custom tags (like "Name" in this example):

```hcl-terraform
resource "aws_db_subnet_group" "database" {
  name        = "${local.res_prefix}-db-subnet-group"
  description = "Database subnet group"
  subnet_ids  = data.terraform_remote_state.network.outputs.private_subnet_ids

  tags = merge(local.default_tags, {
    Name = "${local.res_prefix}-db-subnet-group"
  })
}
```

These tags can be used to categorize resources per system or projects e.g. for operational or billing purposes.

## Resource Groups in AWS Console

This module creates various Resource Groups that can be used to navigate to the resources that are created as part of the demonstration infrastructure. Open AWS Console. Navigate to **Resource Groups & Tag Editor** / Saved Resource Groups: you should see a listing of available resource groups (some of which are created as part of your terraform run, some of which might belong to other users).
