# Dashboard Module

Module for creating a custom [AWS CloudWatch Dashboard](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Dashboards.html).

## Hints for Implementing a Custom AWS CloudWatch Dashboard for Your Project

A nice trick to create a custom Dashboard for your project is to follow this procedure.

1. Open AWS Console.
2. Navigate to CloudWatch / Dashboards view.
3. Click "Created dashboard".
4. Create a custom dashboard manually: add the widgets you are interested to see in your dashboard.
5. When you are ready: Actions / View/edit source. You will see your dashboard as JSON. Copy it.
6. Open the main.tf in this directory. You can replace the dashboard JSON defintion.
7. Remember to change the hardcoded values to the actual references in your project. Examples:

```json
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "my-rds-database" ]
                ],
                "region": "eu-west-1"
            }
```

to:

```json
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${data.terraform_remote_state.rds.outputs.database_instance_identifier}" ]
                ],
                "region": "${data.aws_region.current.id}",
            }
```  

## How to Monitor an AWS System?

You should create good monitoring to your AWS system. Good monitoring includes:

- **Alarms.** You should configure good alarms for the most important metrics you want to monitor. We have provided a couple of alarms for this demonstration: one in the rds module (RDS disk queue depth) and one in the ecs module (Application load balancer unhealthy count). You should also configure the alarms to send notifications to SNS service in which the monitoring personnel have registered their email addresses and phone numbers: they will be notified by email and/or sms message when alarms are triggered. 

- **Dashboard.** You should configure a good dashboard which shows the key metrics of the system. This view provides in one glance the overall healthiness of the system. 