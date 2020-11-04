output "rds_address" {
  value = aws_db_instance.database.address
}

output "rds_port" {
  value = aws_db_instance.database.port
}

output "database_name" {
  value = aws_db_instance.database.name
}

# Note that for actual production use, you would create a less privileged user
# For the demo, we export the master username for use by the application
output "master_user_name" {
  value = aws_db_instance.database.username
}

output "master_password_ssm_parameter_name" {
  value = aws_ssm_parameter.rds_master_password.name
}

output "rds_security_group_id" {
  value = aws_security_group.database.id
}

output "module_name" {
  value = local.module_name
}