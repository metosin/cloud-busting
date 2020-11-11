locals {
  workspace_name = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  module_name    = "common"
  res_prefix     = "${var.prefix}${local.workspace_name}"
  default_tags = {
    Resprefix = local.res_prefix
    Prefix    = var.prefix
    Workspace = terraform.workspace
    Module    = local.module_name
    Terraform = "true"
  }
}

resource "aws_sns_topic" "monitoring" {
  name = "${local.res_prefix}-monitoring-sns"

  tags = merge(local.default_tags, {
    Name = "${local.res_prefix}-monitoring-sns"
  })
}

# When a new monitoring email is added, it is subscribed to the monitoring SNS topic
# Also, when a monitoring email is removed, it is unsubscribed from the monitoring SNS topic
resource "null_resource" "monitoring-email-subscription" {
  count = length(var.monitoring_emails)

  triggers = {
    email   = var.monitoring_emails[count.index]
    sns_arn = aws_sns_topic.monitoring.arn
  }

  # Subscribing and unsubscribing is done by tapping into the Terraform resource Lifecycle

  # Subscription is done when creating the resource
  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${self.triggers.sns_arn} --protocol email --notification-endpoint ${self.triggers.email}"
  }

  # Unsubscription is done when destroying the resource
  provisioner "local-exec" {
    when    = destroy
    command = "aws sns unsubscribe --subscription-arn $(aws sns list-subscriptions-by-topic --topic-arn ${self.triggers.sns_arn} --query 'Subscriptions[?Endpoint == `${self.triggers.email}`].SubscriptionArn' --out text)"
  }
}
