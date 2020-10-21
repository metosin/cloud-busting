variable "prefix" {
  description = "Prefix that is appended to resource names"
  type        = string
}

variable "public-subnet-count" {
  description = "Public subnet count"
  type        = number
  default     = 2
}

variable "private-subnet-count" {
  description = "Private subnet count"
  type        = number
  default     = 2
}

