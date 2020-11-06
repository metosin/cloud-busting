locals {
  rg_name = "${var.rg_name}-rg"
}

resource "aws_resourcegroups_group" "rg" {
  name        = local.rg_name
  description = "Filter-tag is ${var.tag_key} and Filter-value is ${var.tag_value}"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": ["AWS::AllSupported"],
  "TagFilters": [
    {
      "Key": "${var.tag_key}",
      "Values": ["${var.tag_value}"]
    }
  ]
}
JSON
  }
}
