output "ec2_eip_public_ip" {
  value = aws_eip.ec2_eip.public_ip
}

output "module_name" {
  value = local.module_name
}

output "ec2_instance_id" {
  value = aws_instance.bastion-ec2-instance.id
}

output "ec2_instance_az" {
  value = aws_instance.bastion-ec2-instance.availability_zone
}
