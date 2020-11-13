# ECR module

This module provides an ECR ([Elastic Container Registry](https://aws.amazon.com/ecr/)) for the backend application.

## What is an ECR Repository.

ECR is a Docker registry provided by AWS for storing Docker images. You can use these Docker images e.g. in EKS ( [Elastic Kubernetes Service](https://aws.amazon.com/eks/) or ECS ( [Elastic Container Service](https://aws.amazon.com/ecs/) - this demonstration uses ECS.

You must authenticate to the ECR using the AWS IAM ([Identity and Access Management](https://aws.amazon.com/iam/)) service, example:

```bash
aws ecr get-login-password | docker login --username AWS --password-stdin https://<aws_account_id>.dkr.ecr.
```
