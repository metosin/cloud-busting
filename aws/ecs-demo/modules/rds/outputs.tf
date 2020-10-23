output "rds_address" {
  value = aws_db_instance.database.address
}

output "rds_port" {
  value = aws_db_instance.database.port
}
