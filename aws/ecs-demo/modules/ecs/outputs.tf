output "load_balancer_dns_name" {
  value = aws_lb.backend.dns_name
}

output "module_name" {
  value = local.module_name
}
