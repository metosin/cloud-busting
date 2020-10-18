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
