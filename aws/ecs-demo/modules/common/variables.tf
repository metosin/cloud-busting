variable "prefix" {
  description = "Prefix that is appended to resource names"
  type        = string
}

variable "state_bucket" {
  description = "Terraform state bucket"
  type        = string
}
variable "monitoring_emails" {
  description = "List of emails where monitoring alarms are sent to"
  type        = list
  default     = []
}
