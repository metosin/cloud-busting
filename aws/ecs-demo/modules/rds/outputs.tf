output "rds_address" {
  value = aws_db_instance.database.address
}

output "rds_port" {
  value = aws_db_instance.database.port
}

output "rds_security_group_id" {
  value = aws_security_group.database.id
}
