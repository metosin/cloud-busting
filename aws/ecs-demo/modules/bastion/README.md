# Bastion module

The bastion host is meant to be ephemeral, i.e. created when needed and destroyed after use. 

The bastion host provides a secure way to access resources in private subnets. There are a couple of layers that provide protection for the bastion host: The developer IP address needs to be configured to the security group of the bastion host and you also need the SSH key that will be generated automatically by this bastion module.

You can create a SSH tunnel to the RDS via the bastion host. 

With the ephemeral nature of the bastion, sharing the SSH keys to other users is avoided.

## Usage

You are going to need the RDS DNS name later, let's first get it using `aws cli`, by narrowing the DB instance listing with a [JMESPath](https://jmespath.org/) query:

```bash
aws rds describe-db-instances --query 'DBInstances[0].Endpoint.Address' --out text
# Output like:
cbtommi-database.ceiazeowmhxx.eu-west-1.rds.amazonaws.com
```

Bastion module for accessing other resources like RDS via a SSH tunnel.

This module requires you to provide the developer IPs. We need the IP(s) to open ssh port 22 only for those IP(s). You can export the terraform variable like this before the `terraform apply` command:

```bash
curl ifconfig.co
123.456.789.123
export TF_VAR_developer_ips='["123.456.789.123/32"]'
```

When you have applied `terraform apply` command you should get an output  listing the bastion public IP:

```bash
Outputs:
ec2_eip_public_ip = 54.155.131.99
```

This module generates a shh key pair, the private key is stored in the `.ssh` directory of this module, the public key is installed in the bastion. Use the private key to connect to bastion using the IP number that you got as output (the username is `ec2-user`):

```bash
ssh -i .ssh/ec2_id_rsa ec2-user@54.155.131.99
# Output like:
       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
[ec2-user@ip-10-0-0-209 ~]$
```

Now you can create ssh tunnel via bastio to RDS instance:

```bash
./create-ssh-rds-tunnel.sh <LOCAL-PORT-NUMBER>
```

E.g. `./create-ssh-rds-tunnel.sh 6666`

Once the tunnel is ready you can use psql client to connect to the database using the ssh tunnel.

You can get the password of the master user of the DB instance via:

```bash
aws ssm get-parameter --name /rds/master_password --with-decryption --query Parameter.Value --out text
very-secre-...
```

## Bonus Chapter: Use Systems Manager Agent for Tunneling

The Bastion instance in this module reserves a public IP address. You can also try putting the instance into one of the private subnets, remove the Elastic IP (EIP) resource, leave out the aws_key_pair resource and make a tunnel via the AWS Systems Manager Agent (much like described in the [Toward a bastion-less world](https://aws.amazon.com/blogs/infrastructure-and-automation/toward-a-bastion-less-world/) blog post).

In this setup, the SSH key for tunneling can be temporarily created and offered to the instance by the Instance Metadata service, via the [EC2 Connnect API](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-methods.html#ec2-instance-connect-connecting-aws-cli). This setup needs some steps to execute, for which a `ssm-rds-tunnel.sh` script is provided:

```bash
./ssm-rds-tunnel.sh
Warning: Permanently added 'i-05669dd645c436f5a' (ECDSA) to the list of known hosts.
RDS proxy started on localhost at port 7432
Press any key to close session.
Exit request sent.
```
