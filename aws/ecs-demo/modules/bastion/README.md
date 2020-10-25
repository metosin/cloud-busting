# Bastion module

Bastion module for accessing VPC resource (such as the RDS/PostgreSQL database) via a SSH tunnel.

## TODO

* Käytä tähän t4g.nano instanssia, halvin EC2 instanssi nykyään, ARM pohjainen. Valitse ARM -pohjainen AMI, esim. ami-036559f6f83de21be
* Tehdään perinteinen versio, jossa kone istuu public subnetissa ja koneella on Elastic IP.
* Jos jää aikaa, niin tehdään myös versio, jossa kone onkin private subnetissa, ei julkista osoitetta, käytetään SSM -agenttia tunnelointiin, lisätään vaikkapa tools -hakemistoon tämän tyylinen scripti, kuin Jabster projektissa: https://github.com/metosin/jabster/blob/master/tools/rds_proxy
