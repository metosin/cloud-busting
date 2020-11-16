resource "aws_cloudwatch_metric_alarm" "rds_disk_queue_depth_alarm" {
  alarm_name          = "${local.res_prefix} rds disk queue depth alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DiskQueueDepth"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "5"
  # Should be defined in some project related parameter file.
  alarm_description = "Monitors RDS disk queue depth"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.database.identifier
  }

  alarm_actions = [data.terraform_remote_state.common.outputs.monitoring_sns_topic_arn]
  ok_actions    = [data.terraform_remote_state.common.outputs.monitoring_sns_topic_arn]

  tags = merge(local.default_tags, {
    Name = "${local.res_prefix}-rds-disk-queue-depth-alarm"
  })
}

