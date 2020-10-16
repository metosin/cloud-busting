# bootstrap

Module for creating Terraform state resources.

## Usage

    export AWS_DEFAULT_REGION=eu-west-1
    terraform init
    # Check plan with:
    TF_VAR_prefix=cb-kimmo terraform plan
    # Apply plan with
    TF_VAR_prefix=cb-kimmo terraform apply
