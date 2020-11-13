# Common Shared Resources Module

Contains resources that don't strictly have a logical place (such as VPC or a RDS database would), but can be used from many other modules.

Contains `aws_sns_topic` for monitoring use and a list of emails that can be registered for receiving alarms.

The input variable `monitoring_emails` lists the email addresses to which an email is sent in case the alarm is triggered.

In the demo, the list of emails is empty by default, but you can define your own email during apply:

```bash
TF_VAR_monitoring_emails='["my-email@example.com"]' terraform apply
```

The email address is then added to a SNS topic and a confirmation is sent to the email address to accept the reception of messages from the SNS topic. So check your mailbox after adding the email.

## SNS Topic

[SNS](https://aws.amazon.com/sns/) (Simple Notification Service) provides a way to broadcast messages to topics to which subscriptions can be made (e.g. http endpoint, email, sms). Typically SNS is used by system operators to subscribe certain topics to which alarms send notifications. This demonstration provides a couple of alarms that use the topic in this module.
