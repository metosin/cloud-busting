variable "prefix" {
  description = "Prefix that is appended to resource names"
  type        = string
}

variable "state_bucket" {
  description = "Terraform state bucket"
  type        = string
}

variable "public_port" {
  description = "Port for traffic from public internet"
  type        = number
}

variable "backend_port" {
  description = "Backend traffic port"
  type        = number
}

variable "elb_account_id" {
  description = "Account ID of the ELB service. We use eu-west-1 in the demo. See id's for other regions from https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html"
  type        = string
  default     = "156460612806"
}

variable "backend_cpu" {
  description = "CPU value for the Fargate task"
  default     = 512
}

variable "backend_memory" {
  description = "Memory value for the Fargate task"
  default     = 1024
}
