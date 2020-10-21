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

Then issuing

    tfswitch

Provides a menu to select Terraform version.

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
