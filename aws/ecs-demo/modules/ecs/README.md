# ECS module

This module creates a [ECS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html) (Elastic Container Service) cluster with one service that runs 2 tasks with [Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html) launch type.

ECS is a service for running Docker containers on a cluster of hosts. Fargate is a service that ECS can use to launch Docker containers. Tasks are a way to tell ECS the parameters to pass to `docker run` invocation (e.g. image, environment variables...). To explain what Fargate is, we first explain how one would traditionally run Docker containers in a set of virtual machines with ECS.

Traditionally, one would provision a EC2 Instance(s) with Docker Daemon and the ECS Agent installed (The [ECS Optimized AMI](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html) already has all components installed) and instruct the host to [join the ECS cluster](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/bootstrap_container_instance.html).

With Fargate, instead of provisioning a whole Virtual Machine, the ECS service requests an isolated CPU, memory and networking interface from the Fargate service. The Fargate runtime uses a minimalistic VM, called [Firecracker](https://firecracker-microvm.github.io/) to run the Docker container. Instead of choosing an EC2 instance type to run on, the CPU and memory configuration is specified in the Task configuration from a set of [pre-defined options](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-tasks-size).

In addition to ECS, Fargate can also be used by the [EKS](https://aws.amazon.com/eks) (Elastic Kubernetes Service).

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

### Alarms

The example creates and alarm for UnHealthyHostCount metric, which is the number of backends that have failing health check.

The input variable `monitoring_emails` lists the email addresses to which an email is sent in case the alarm is triggered.

In the demo, the list of emails is empty, but you can define your own email during apply:

```bash
TF_VAR_monitoring_emails='["my-email@example.com"]' terraform apply
```

The email address is then added to a SNS topic and a confirmation is sent to the email address to accept the reception of messages from the SNS topic. So check your mailbox after adding the email.

## Destroy

Destroy the resources by running:

```bash
terraform destroy
```

Destroy will also prompt for the Git tag input variable, but the value will not matter in this case, since no new resource will be created.
