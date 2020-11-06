resource "aws_cloudwatch_metric_alarm" "healthy-host-count" {
  alarm_name          = "${local.res_prefix} backend healthy host count"
  alarm_description   = "${local.res_prefix} Healthy host count"
  comparison_operator = "GreaterThanThreshold"

  threshold = 0

  # See the available metric and namespace names from https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html
  metric_name = "UnHealthyHostCount"
  namespace   = "AWS/ApplicationELB"

  # We match only our own load balancer and the target group
  dimensions = {
    LoadBalancer = aws_lb.backend.arn_suffix
    TargetGroup  = aws_lb_target_group.backend.arn_suffix
  }

  evaluation_periods = "1"
  period             = "300"
  statistic          = "Maximum"

  # Often times, missing data causes noisy alerts, so ignored here. But this depends on the metric at hand.
  treat_missing_data        = "ignore"
  insufficient_data_actions = []

  alarm_actions = [aws_sns_topic.monitoring.arn]
  ok_actions    = [aws_sns_topic.monitoring.arn]
}

resource "aws_sns_topic" "monitoring" {
  name = "monitoring"
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
