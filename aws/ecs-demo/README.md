# ecs-demo

A web application that is deployed to AWS via Terraform and is run in Elastic Container Service (ECS) using Fargate
runtime, reads data from a RDS/PostgreSQL data store and is accessible from public internet via a Application Load
Balancer (ALB).


# TODO

TODO: Pitää ajaa terraform fmt koko setille lopuksi

TODO: modulien ajojärjestys pitää ohjeistaa

TODO: pitää ohjeistaa, että jos tekee omia uusia moduleita, niin `key` terraform staten pitää olla uniikki:

TODO: voisi laittaa source ../../../tools/terraform-init valittamaan jo TF_VAR_prefix ei asetettu

```hcl-terraform
data "terraform_remote_state" "network" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    key    = "ecs-demo-network.tfstate"   # ====> This needs to be unique.
    bucket = var.state_bucket
  }
}
``` 

If you e.g. create a new module `s3`, you have to create a `setup.tf` file and there you need to have a unique `key`, e.g. `"ecs-demo-s3.tfstate"`

```hcl-terraform
    key    = "ecs-demo-s3.tfstate"   # ====> This needs to be unique.
```  
