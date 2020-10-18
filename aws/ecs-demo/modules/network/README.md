# network

A module that contains base networking resources: VPC, private and public subnets, NAT gateway and internet gateway and
router tables that route traffic to internet gateway from the public subnet and to NAT gateway from the private subnet.

## Usage

First, initialize the backend with:

    $ source ../../../tools/terraform-init

    Initializing the backend...

    Successfully configured the backend "s3"! Terraform will automatically
    use this backend unless the backend configuration changes.

    Initializing provider plugins...
    - Finding hashicorp/aws versions matching "3.11.0"...
    - Installing hashicorp/aws v3.11.0...
    - Installed hashicorp/aws v3.11.0 (signed by HashiCorp)

    Terraform has been successfully initialized!

    You may now begin working with Terraform. Try running "terraform plan" to see
    any changes that are required for your infrastructure. All Terraform commands
    should now work.

    If you ever set or change modules or backend configuration for Terraform,
    rerun this command to reinitialize your working directory. If you forget, other
    commands will detect it and remind you to do so if necessary.

After backend initialization, other Terraform commands can be run, for example, check the plan via

    $ terrafrom plan

And apply changes via

    $ terraform apply

### Usage with workspaces

To create a new network, for example for feature branches, first create a new workspace


    $ terraform workspace new experiment
    Created and switched to workspace "experiment"!

    You're now on a new, empty workspace. Workspaces isolate their state,
    so if you run "terraform plan" Terraform will not see any existing state
    for this configuration.

Then run other Terraform commands normally. To see a list of workspaces, run:

    $ terraform workspace list
    default
    * experiment

After the experiment is done, destroy infrastructure with `destroy` command.

    $ terraform destroy

To return to default workspace, run:

    $ terraform workspace select default
    Switched to workspace "default".
