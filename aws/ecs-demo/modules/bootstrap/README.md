# bootstrap

Module for creating resources for [Terraform backend state](https://www.terraform.io/docs/backends/index.html) stored in S3, with concurrent operations prevented by a lock in DynamoDB table.

## Usage

    # First, initialize the local backend
    $ terraform init
    Initializing the backend...

    Initializing provider plugins...
    - Using previously-installed hashicorp/aws v3.11.0

    Terraform has been successfully initialized!

    You may now begin working with Terraform. Try running "terraform plan" to see
    any changes that are required for your infrastructure. All Terraform commands
    should now work.

    If you ever set or change modules or backend configuration for Terraform,
    rerun this command to reinitialize your working directory. If you forget, other
    commands will detect it and remind you to do so if necessary.

    # Check plan with:
    $ terraform plan
    ...

    # Apply plan with
    $ terraform apply

As last, commit `terraform.tfstate` file, which is is local backend state file, into version control, so that the bootstrap state is persisted off your computer.
