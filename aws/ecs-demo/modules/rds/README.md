# Rds Module

A module that contains one RDS (database) resource.

NOTE: It may well take some 10 minutes to create the RDS module, so be patient.

## Secrets

When creating a RDS instance, a single user is created, called the master user, which owns the initial database. A password needs to be specified for the user, so we need a way to securely pass the password to the API call that creates the DB instance.

In Terraform, all resource attributes are stored into the Terraform backend state, which includes secret information also. This is why the backend state file is encrypted at rest with a KMS key in this example.

With tools such as Ansible, it is common to use [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html) to store secrets into symmetrically encrypted files that are stored in version control (or encrypt specific variables by encrypting the variable string itself). Managing the access to the encryption key is then left to the project team or operations team.

With Terraform, there isn't a single specific solution for this task. In this demo, we've chosen to use a tool by Mozilla called [Sops](https://github.com/mozilla/sops): Secrets OPerationS.

This tools takes a similar approach to Ansible Vault in variable string encryption mode. The `sops` tool can be used to encrypt the **values** of JSON or YAML formatted properties.

We use a Terraform provider, [terraform-provider-sops](https://github.com/carlpett/terraform-provider-sops) to integrate Sops into Terraform.

This way, we can store an encrypted file into version control and decrypt the contents into use by Terraform.

# Explanation

TODO: here short explanation to the resources and why they are created...

TODO: RDS password: how to inject this value
