# Installing Terraform

There are few ways of installing Terrafrom:

1. Manual installation
2. Using Homebrew
3. TFSwitch

## 1. Manual installation from archive

1. Download Terraform from [download site](https://www.terraform.io/downloads.html).
2. Unzip the archive and put it into `$PATH`

## 2. Using Homebrew

Use the [Homebrew formulae](https://formulae.brew.sh/formula/terraform)

    brew install terraform

## 3. Using [tfswitch](https://tfswitch.warrensbox.com/)


Tfswitch keeps the Terraform binaries stored under `$HOME/.terraform.versions`, which helps switching version especially when managing multiple Terraform projetcs.


### OS X
First, install `tfswitch` via [instructions](https://tfswitch.warrensbox.com/Install/), for example (Note: this conflicts with the `terraform` formulae in option 2., so chooce one or the other solution)

    brew install warrensbox/tap/tfswitch

Then run `tfswith` to select a Terraform version:

```bash
0% tfswitch
Reading required version from terraform file, constraint: = 0.13.4
Matched version: 0.13.4
Switched terraform to version "0.13.4"
```

tfswitch will read the `version.tf` file found the root directory of the repository, and selects the version specified in that file, which helps to make sure everyone in your team is using the same version of Terraform. Otherwise a menu for selectin the version will be shown.

### Linux

For Linux users, install binaries to a folder which is in `PATH`, often e.g. `$HOME/bin`:

```bash
bash <(curl -s https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh) -b ${HOME}/bin
```

This will install both `terraform` and `tfswitch` commands, and keep `terraform` file linked to the selected version.
