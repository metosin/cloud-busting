# Bastion module

TODO: Tähän idea bastionista:
- Bastion on ephemeral: luodaan on-demand. Kun ei tarvita, niin tuhotaan, jolloin myös avain tuhoutuu.
- Kun bastion luodaan per käyttäjä on-demand ja bastion ei ole muuna aikana ylhäällä, niin vähennetään hyökkäyspintaa.


You are going to need the RDS DNS name later, let's first get it using `aws cli`, by narrowing the DB instance listing with a [JMESPath](https://jmespath.org/) query:

```bash
aws rds describe-db-instances --query 'DBInstances[0].Endpoint.Address' --out text
# Output like:
cbtommi-database.ceiazeowmhxx.eu-west-1.rds.amazonaws.com
```

Bastion module for accessing other resources like RDS via a SSH tunnel.

This module requires you to provide the developer IPs. We need the IP(s) to open ssh port 22 only for those IP(s). You can export the terraform variable like this before the `terraform apply` command:
 
 ```bash
 export TF_VAR_developer_ips='["88.197.213.214/32", "88.191.114.113/32"]'
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



## TODO

* Käytä tähän t4g.nano instanssia, halvin EC2 instanssi nykyään, ARM pohjainen. Valitse ARM -pohjainen AMI, esim. ami-036559f6f83de21be
* Tehdään perinteinen versio, jossa kone istuu public subnetissa ja koneella on Elastic IP.
* Jos jää aikaa, niin tehdään myös versio, jossa kone onkin private subnetissa, ei julkista osoitetta, käytetään SSM -agenttia tunnelointiin, lisätään vaikkapa tools -hakemistoon tämän tyylinen scripti, kuin Jabster projektissa: https://github.com/metosin/jabster/blob/master/tools/rds_proxy
