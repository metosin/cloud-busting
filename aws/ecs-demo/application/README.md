# Simple webapp

A simple webapp with a handler that returns the version it is running. Run in ECS with Fargate via the [ecs Terraform module](../modules/ecs/).

## Building docker image

The application uses [pack.alpha](https://github.com/juxt/pack.alpha#docker-image) library to build a docker image. The `build.sh` script creates the image and pushes it into ECR repository defined in the [ecs](../modules/ecr) module.

So to build and push the image, you must first create the ECR repository:

```bash
cd ../modules/ecr
source ../../../tools/terraform-init
terraform apply
```

Then, [install](https://github.com/awslabs/amazon-ecr-credential-helper#installing) and [configure](https://github.com/awslabs/amazon-ecr-credential-helper#configuration) the [ECR credential helper](https://github.com/awslabs/amazon-ecr-credential-helper) to authenticate to the ECR repository for pushing the image:

For example, add:

```json
{
	"credHelpers": {
		"<your aws_account_id>.dkr.ecr.region.amazonaws.com": "ecr-login"
	}
}
```

to

```
~/.docker/config.json
```

After this, build the application:

```bash
./build.sh
123456789012.dkr.ecr.eu-west-1.amazonaws.com/cbkimmo-backend
WARNING: Use of :deps in aliases is deprecated - use :replace-deps instead
WARNING: When invoking clojure.main, use -M
Building 123456789012.dkr.ecr.eu-west-1.amazonaws.com/cbkimmo-backend:abc1234
[=========================================         ]  83/100  03:41
```

Take note of the image tag (`abc1234` in the above example). This is needed when deploying the application via the [ecs module](../modules/ecs).
