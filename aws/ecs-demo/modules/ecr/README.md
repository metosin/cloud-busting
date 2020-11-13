# ECR module

This module provides an [ECR](https://aws.amazon.com/ecr/) (Elastic Container Registry) for the backend application.

## What is an ECR Repository.

ECR is a Docker registry provided by AWS for storing Docker images. You can use these Docker images e.g. in [EKS](https://aws.amazon.com/eks/) (Elastic Kubernetes Service) or [ECS](https://aws.amazon.com/ecs/) (Elastic Container Service) - this demonstration uses ECS.

You must authenticate to the ECR using the [IAM](https://aws.amazon.com/iam/) (Identity and Access Management) service, example:

```bash
aws ecr get-login-password | docker login --username AWS --password-stdin https://<aws_account_id>.dkr.ecr.
```
