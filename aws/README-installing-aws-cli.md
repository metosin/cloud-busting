# Installing AWS CLI

For configuring the AWS cli you first need the AWS Access Key ID and AWS Secret Access Key. You can create these keys for yourself in AWS Console, IAM view / Users / select your user / Security Credentials tab / Create access key button. We assume that your user has rights to create the resources needed in this demonstration. 

Follow [AWS CLI instructions](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) to install AWS cli. After installation, configure credentials by following [the instructions](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html). Usually, this can be done by running the basic configuration wizard:

```bash
aws configure --profile <YOUR PROFILE NAME>
AWS Access Key ID [None]: <YOUR ACCESS KEY ID HERE>
AWS Secret Access Key [None]: <YOUR SECRET ACCESS KEY HERE>
Default region name [None]: eu-west-1
Default output format [None]: json
```

We assume that you use `eu-west-1` region for all the resources - it is a best practice to use a dedicated region.

For more information you can read [AWS instructions](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) how to create an AWS profile.
