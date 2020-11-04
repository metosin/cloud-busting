output "ec2_eip_public_ip" {
  value = aws_eip.ec2_eip.public_ip
}

output "module_name" {
  value = local.module_name
}
