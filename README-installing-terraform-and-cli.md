# Installing Terraform

There are few ways of installing Terrafrom:

## Manual installation from archive

1. Download Terraform from [download site](https://www.terraform.io/downloads.html).
2. Unzip the archive and put it into `PATH`

## Using Homebrew

Use the [Homebrew formulae](https://formulae.brew.sh/formula/terraform)

    brew install terraform

## Using [tfswitch](https://tfswitch.warrensbox.com/)

First, install `tfswitch` via [instructions](https://tfswitch.warrensbox.com/Install/), for example

    brew install warrensbox/tap/tfswitch

Then run `tfswith` to select a Terraform version:

```bash
tfswitch
Use the arrow keys to navigate: ↓ ↑ → ←
? Select Terraform version:
  ▸ 0.13.5 *recent
    0.13.4
    0.13.3
    0.13.2
↓   0.13.1
```

For Linux users, specify a binary that under the `$HOME` directory (in OSX, writing to `/usr/local/bin` is usually allowed):

```bash
mkdir $HOME/bin
export PATH=$PATH:$HOME/bin
tfswitch -b $HOME/bin/terraform
```

Tfswitch keeps the Terraform binaries store under `$HOME/.terraform.versions`, which helps switching version especially when managing multiple Terraform projetcs.

Tfswitch has the advantage of being able to [specify the required Terraform
version](https://www.terraform.io/docs/configuration/terraform.html#specifying-a-required-terraform-version) in a [configurafion](https://tfswitch.warrensbox.com/Quick-Start/#use-versiontf-file) file, which helps to make sure everyone in your team is using the same version of Terraform:

    $ cat version.tf
    terraform {
      required_version = "= 0.13.4"
    }
    $ tfswitch
    Reading required version from terraform file, constraint: = 0.13.4
    Matched version: 0.13.4
    Switched terraform to version "0.13.4"

# Installing AWS CLI

Follow [AWS CLI instructions](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html). After installation, configure credentials by following [the instructions](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html). Usually, this can be done by running the basic configuration wizard:

```bash
aws configure
AWS Access Key ID [None]: <YOUR ACCESS KEY ID HERE>
AWS Secret Access Key [None]: <YOUR SECRET ACCESS KEY HERE>
Default region name [None]: eu-west-1
Default output format [None]: json
```

For the demo, we'll use `eu-west-1` region for all the resources.
