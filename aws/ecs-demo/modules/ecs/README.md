# Webapp run via ECS service

Module for running a simple webapp with AWS [ECS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html) (Elastic Container Service) using [Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html) runtime.

## Create

Create the service by first initializing the module:

```bash
source ../../../tools/terraform-init
```

Running apply will ask for a Git hash of the Docker image to run. This is the tag the [application image](../../application) was tagged with.

```bash
terraform apply
var.image_tag
  Docker image tag to run by the service. Usually a Git SHA

  Enter a value: 89257e6
data.terraform_remote_state.network: Refreshing state...
data.terraform_remote_state.ecr: Refreshing state...
...
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_security_group.lb: Creating...
aws_cloudwatch_log_group.backend: Creating...
...
Apply complete! Resources: 19 added, 0 changed, 0 destroyed.
Releasing state lock. This may take a few moments...

Outputs:

load_balancer_dns_name = cbkimmo-backend-580158845.eu-west-1.elb.amazonaws.com
```

Copy the DNS name of the load balancer from the output of the apply command and check the service state after (wait before the initial registration delay, which is 30 seconds):

```bash
curl cbkimmo-backend-580158845.eu-west-1.elb.amazonaws.com
Hello World! Running at 89257e6. Database has 27 connections
```

## Destroy

Destroy the resources by running:

```bash
terraform destroy
```

Destroy will also prompt for the Git tag input variable, but the value will not matter in this case, since no new resource will be created.
