variable "prefix" {
  description = "Prefix that is appended to resource names"
  type        = string
}

variable "state_bucket" {
  description = "Terraform state bucket"
  type        = string
}

# You can find this AMI id e.g. in AWS Console in EC2 Service when launching a new AMI
# in Step 1: Choose an Amazon Machine Image (AMI)
# ami-036559f6f83de21be is Amazon Linux 2, ARM, in Ireland.
variable "ami_id" {
  description = "AMI id"
  type        = string
  default     = "ami-036559f6f83de21be"
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t4g.nano"
}

# Provide your workstation IP here.
# Will be used in bastion ingress rule.
# Provide as ["99.195.212.215/32", "99.195.212.216/32"]
# Export the list e.g.:
# export TF_VAR_developer_ips='["99.195.212.215/32", "99.195.212.216/32"]'
variable "developer_ips" {
  description = "Developer workstation IPs (list as [ \"99.195.212.215/32\", \"99.195.212.216/32\" ] "
  type        = list(string)
  #default = ["88.195.214.218/32", "88.195.214.219/32"]
}

variable "tenancy_type" {
  description = "Tenancy type"
  type        = string
  default     = "default"
}