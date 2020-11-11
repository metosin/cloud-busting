output "monitoring_sns_topic_arn" {
  value = aws_sns_topic.monitoring.arn
}

output "module_name" {
  value = local.module_name
}

