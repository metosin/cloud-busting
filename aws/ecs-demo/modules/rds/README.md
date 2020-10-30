# Rds Module

A module that contains one RDS (database) resource.

NOTE: It may well take some 10 minutes to create the RDS module, so be patient.

## Specifying Master User Password

When creating a RDS instance, a single user is created, called the master user, which owns the initial database. A password needs to be specified for the user, so we need a way to securely pass the password to the API call that creates the DB instance and store the password.

In this example, we've chosen to use the [sops](https://github.com/mozilla/sops) tool by Mozilla. As per the [general secrets instructions](https://github.com/metosin/cloud-busting/blob/main/aws/README.md#secrets), **before** running `plan` or `apply` commands, specify the password in a file encrypted with a KMS key created when the Terraform backend was created:

1. Initialize the module
```bash
source ../../../tools/terraform-init
```

2. Create `vars/secrets.json` with
```bash
sops vars/secrets.json
```

This will open an editor with sample JSON content content. Replace the content with the following:

```json
{
  "rds_master_password": "very-secret-string"
}
```

Hint: Use for example `openssl rand -hex 32` to generate a password.

4. Commit `vars/secrets.json` into version control
```bash
git commit -a
```

This way, we can store an encrypted file into version control and decrypt the contents into use by Terraform.

# Explanation

TODO: here short explanation to the resources and why they are created...
