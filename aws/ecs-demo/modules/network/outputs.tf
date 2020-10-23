output "vpc_id" {
  value = aws_vpc.main.id
}

output "pubic_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}
