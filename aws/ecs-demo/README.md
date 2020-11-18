# ecs-demo

## Introduction

This directory contains an AWS infrastructure demonstration comprising of a Virtual Private Cloud (VPC), Elastic Container Service (ECS) and Relational Database Service (RDS), and one application that will be deployed to ECS. 

The web application is packaged into a Docker image. The Elastic Container Service (ECS) is using the Fargate launch type. Fargate is used to remove the need to provision virtual machines for running Docker containers.

The Fargate runtime is connected to a private subnet (which does not have direct route to public internet). A RDS/PostgreSQL database instance is also attached to the private subnet. Application Load Balancer (ALB) is then deployed to a public subnet, in order to expose the application to the public internet. A bastion host module is also provided for SSH tunneling.

The architecture picture below shows the network structure, along how the services are situated in the subnets.

![network-architecture.png](network-architecture.png)

The module setup is meant to mimic a real life project, so it might be more complex than what is absolutely necessary for a minimal Fargate based web service. To regain simplicity in creating the infrastructure, helper scripts are provided for apply/destroy the whole suite in one go.

## Usage

### 1. Preparation: Terraform Backend

**NOTE**: If you have followed the instructions this far you have already created the Terraform backend. If not, then to bring the resources into life, we first need to create a Terraform backend, which stores the state of each resource. To do this, follow the instructions in the [terraform-backend directory](../terraform-backend) directory.

### 2. Preparation: Install Sops Tool

We have decided to use the Sops tool for storing secrets as encrypted files in version control.

1. Install the [sops](https://github.com/mozilla/sops) tool from [Releases](https://github.com/mozilla/sops/releases) page. Either download and install the installation package, or download the sops binary and put it into `$PATH`.
2. Specify the master password for RDS/PostgreSQL instance:

2.1. Go to [rds](modules/rds) directory.
```bash
cd modules/rds
```

2.2. Initialize the module
```bash
source ../../../tools/terraform-init
```

2.3. Create `vars/secrets.json` with
```bash
sops vars/secrets.json
```

This will open an editor with sample JSON content content. Replace the content with the following:

```json
{
  "rds_master_password": "very-secret-string"
}
```

2.4. Go back to ecs-demo directory.
```bash
cd ../..
```

Now you have done all preparations. It might feel that you needed to do a lot of stuff just to set up the infrastructure but the preparations are a one time task. From now on in real projects the developer just modifies the infrastructure files and applies the changes.

Now it is time for you to fetch a cup of coffee or some snack, and create all the resources. It takes about 20 minutes to create all the resources.

### 3. Fast Track: Create All Resources with Helper Script

Run the `apply-all.sh` script
```bash
./apply-all.sh
```

Sit back and watch the fireworks 🎆 :) 

The `apply-all.sh` script runs `terraform init/apply` in each module. You can also run `terraform init/plan/apply` manually in each module yourself. If you choose to do so, you have to run `terraform init/apply` in the modules using the order as described in the [dependency order](modules/README.md#module-dependencies).

### 4. Study The Created Resources in AWS Console

While resources are being created, sign into the AWS Console and study for example the [VPC](https://eu-west-1.console.aws.amazon.com/vpc/home?region=eu-west-1#vpcs:) (Virtual Private Cloud), [RDS](https://eu-west-1.console.aws.amazon.com/rds/home?region=eu-west-1#databases:) (Relational Database Service), [ECS](https://eu-west-1.console.aws.amazon.com/ecs/home?region=eu-west-1#/clusters) (Elastic Container Service) Consoles. When all the resources are created, the [Resource Groups](https://eu-west-1.console.aws.amazon.com/resource-groups/home?region=eu-west-1#) Console will provide a place to navigate to all the resources. 


### 5. Last Step: Destroy

When the resources are no longer needed, they can be destroyed via `destroy-all.sh` script.

Either run `terraform destroy` individually in all modules in dependency order, or run the `destroy-all.sh` script, which does the required steps in dependency order in one go.
