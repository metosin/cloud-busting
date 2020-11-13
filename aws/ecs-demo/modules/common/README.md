# Common Shared Resources Module

Contains resources that don't strictly have a logical place (such as VPC or a RDS database would), but can be used from many other modules.

Contains `aws_sns_topic` for monitoring use and a list of emails that can be registered for receiving alarms.

## SNS Topic

[SNS](https://aws.amazon.com/sns/) (Simple Notification Service) provides a way to broadcast messages to topics to which subscriptions can be made (e.g. http endpoint, email, sms). Typically SNS is used by system operators to subscribe certain topics to which alarms send notifications. This demonstration provides a couple of alarms that use the topic in this module.
