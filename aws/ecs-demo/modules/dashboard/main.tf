locals {
  workspace_name   = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  module_name      = "dashboard"
  res_prefix       = "${var.prefix}${local.workspace_name}"
  private_key_name = "ec2_id_rsa"
  default_tags = {
    Resprefix = local.res_prefix
    Prefix    = var.prefix
    Workspace = terraform.workspace
    Module    = local.module_name
    Terraform = "true"
  }
}

data "aws_region" "current" {}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${local.res_prefix}-dashboard"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/RDS", "DiskQueueDepth", "DBInstanceIdentifier", "${data.terraform_remote_state.rds.outputs.database_instance_identifier}" ]
                ],
                "region": "${data.aws_region.current.id}",
                "title": "Disk Queue Depth"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ECS", "CPUUtilization", "ServiceName", "${data.terraform_remote_state.ecs.outputs.ecs_service_name}", "ClusterName", "${data.terraform_remote_state.ecs.outputs.ecs_cluster_name}" ]
                ],
                "region": "${data.aws_region.current.id}",
                "title": "ECS CPU Utilization"
            }
        }
    ]
}
EOF
}
