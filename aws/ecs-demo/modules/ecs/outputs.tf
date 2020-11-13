output "load_balancer_dns_name" {
  value = aws_lb.backend.dns_name
}

output "module_name" {
  value = local.module_name
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.backend.name
}

output "ecs_service_name" {
  value = aws_ecs_service.backend.name
}
