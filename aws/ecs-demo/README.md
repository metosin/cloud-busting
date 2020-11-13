# ecs-demo

This directory contains a demonstration of a Virtual Private Cloud (VPC) created for running applications. For simplicity, only a single web applicationis run, packaged into Docker image and run via the Elatics Container Service (ECS) using the Fargate launch type. Fargate is used to remove the need to provision virtual machines for running Docker containers.

The Fargate runtime is connected to a private subnet (which does not have direct route to public internet). A RDS/PostgreSQL database instance is also attached to the private subnet. Application Load Balancer (ALB) is then deployed to a public subnets, in order to expose the application to the public internet. A bastion host module is also provided for SSH tunneling.

The architecture picture below shows the network structure, along how the services are situated in the subnets.

![network-architecture.png](network-architecture.png)

The module setup is meant to mimic a real life project, so it might be more complex than what is absolutely necessary for a minimal Fargate based web service. To regain simplicity in creating the infrastructure, [helper scripts](https://github.com/metosin/cloud-busting/blob/main/aws/ecs-demo/modules/README.md#fast-track-for-apply-and-destroy) are provided for apply/destroy the whole suite in one go.

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
