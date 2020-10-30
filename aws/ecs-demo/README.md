# ecs-demo

A web application that is deployed to AWS via Terraform and is run in Elastic Container Service (ECS) using Fargate
runtime, reads data from a RDS/PostgreSQL data store and is accessible from public internet via a Application Load
Balancer (ALB).

TODO: diagrams using mermaid or graphviz

TODO: Module dependency graph ()
- ecr
- network
-- ecs
-- rds 
---- bastion


TODO: Painota, että tämä demo on mahdollisimman todenmukainen refe-toteutus, ja sen takia demossa on jonkin verran manuaalisia one-time taskeja. Olisimme voineet myös tehdä demon, jossa yhdellä komennolla saa koko infran aikaan, mutta päädyimme sen sijaan todenmukaisempaan ratkaisuun, jossa on mukana terraform modulien joustavuus ja oikean projektin tietoturva.


TODO: Demo-käsikirjoitus pitää olla todella selkeä ja se pitää harjoitella pari kertaa läpi, ettei tule virheitä eikä väärinkäsityksiä!




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
