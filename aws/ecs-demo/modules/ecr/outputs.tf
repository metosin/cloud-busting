output "backend_repository_url" {
  description = "URL of the ECR repository for backend"
  value = aws_ecr_repository.backend.repository_url
}
