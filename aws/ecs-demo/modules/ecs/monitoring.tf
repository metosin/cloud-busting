resource "aws_cloudwatch_metric_alarm" "unhealthy-host-count" {
  alarm_name          = "${local.res_prefix} backend unhealthy host count"
  alarm_description   = "${local.res_prefix} Unhealthy host count"
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

  alarm_actions = [data.terraform_remote_state.common.outputs.monitoring_sns_topic_arn]
  ok_actions    = [data.terraform_remote_state.common.outputs.monitoring_sns_topic_arn]

  tags = merge(local.default_tags, {
    Name = "${local.res_prefix}-ecs-backend-unhealthy-host-count"
  })
}

