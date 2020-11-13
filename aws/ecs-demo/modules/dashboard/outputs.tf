output "module_name" {
  value = local.module_name
}

output "default_region" {
  value = data.aws_region.current.id
}

