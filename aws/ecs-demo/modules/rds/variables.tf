variable "prefix" {
  description = "Prefix that is appended to resource names"
  type        = string
}

variable "state_bucket" {
  description = "Terraform state bucket"
  type        = string
}

variable "rds_port" {
  description = "RDS port"
  type        = number
  default     = 5432
}

variable "allocated_storage" {
  description = "Allocated db storage"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Max allocated db storage when autoscaling"
  type        = number
  default     = 30
}

variable "instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t3.small"
}

variable "maintenance_window" {
  description = "Database maintenance window"
  type        = string
  default     = "Mon:04:00-Mon:06:00"
}

variable "backup_window" {
  description = "Daily automated backup window"
  type        = string
  default     = "01:00-02:00"
}

variable "backup_retention_period" {
  description = "Days to retain automated backups"
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot"
  type        = bool
  default     = true
}

variable parameter_group_parameters {
  description = "Database parameter group values"
  type = list(object({
    name         = string
    value        = number
    apply_method = string
  }))
  default = [
    {
      name         = "auto_explain.log_min_duration"
      value        = 500
      apply_method = "immediate"
    }
  ]
}