locals {
  workspace_name = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  module_name    = "rds"
  res_prefix     = "${var.prefix}${local.workspace_name}"
  default_tags = {
    Resprefix = local.res_prefix
    Prefix    = var.prefix
    Workspace = terraform.workspace
    Module    = local.module_name
    Terraform = "true"
  }
}

data "aws_vpc" "main" {
  id         = data.terraform_remote_state.network.outputs.vpc_id
  cidr_block = data.terraform_remote_state.network.outputs.vpc_cidr_block
}

resource "aws_security_group" "database" {
  name        = "${local.res_prefix}-database-sg"
  description = "Database security group"
  vpc_id      = data.aws_vpc.main.id

  # NOTE: Alternative is to allow access only from bastion and ECS.
  ingress {
    description = "Allow traffic from VPC to RDS"
    from_port   = var.rds_port
    to_port     = var.rds_port
    protocol    = "tcp"
    cidr_blocks = [
    data.aws_vpc.main.cidr_block]
  }

  egress {
    description = "Allow traffic from RDS to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  tags = merge(local.default_tags, {
    Name = "${local.res_prefix}-database-sg"
  })
}

resource "aws_db_subnet_group" "database" {
  name        = "${local.res_prefix}-db-subnet-group"
  description = "Database subnet group"
  subnet_ids  = data.terraform_remote_state.network.outputs.private_subnet_ids

  tags = merge(local.default_tags, {
    Name = "${local.res_prefix}-db-subnet-group"
  })
}

resource "aws_kms_key" "rds_key" {
  description = "Key for encrypting RDS"

  tags = merge(local.default_tags, {
    Name = "${local.res_prefix}-rds-key"
  })
}

resource "aws_kms_alias" "rds_kms_alias" {
  name          = "alias/${local.res_prefix}-rds-kms-alias"
  target_key_id = aws_kms_key.rds_key.key_id
}

resource "aws_db_parameter_group" "database" {
  name   = "${local.res_prefix}-db-parameter-group"
  family = "postgres12"

  dynamic "parameter" {
    for_each = var.parameter_group_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = merge(local.default_tags, {
    Name = "${local.res_prefix}-db-parameter-group"
  })
}

data "sops_file" "secrets" {
  source_file = "vars/secrets.json"
}

resource "aws_db_instance" "database" {
  identifier              = "${local.res_prefix}-database"
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.max_allocated_storage
  storage_type            = "gp2"
  skip_final_snapshot     = var.skip_final_snapshot
  engine                  = "postgres"
  engine_version          = "12.4"
  instance_class          = var.instance_class
  name                    = "ecsdemo"
  username                = "ecsdemo"
  password                = data.sops_file.secrets.data["rds_master_password"]
  port                    = var.rds_port
  maintenance_window      = var.maintenance_window
  backup_window           = var.backup_window
  backup_retention_period = var.backup_retention_period
  vpc_security_group_ids = [
  aws_security_group.database.id]
  db_subnet_group_name                = aws_db_subnet_group.database.name
  iam_database_authentication_enabled = true
  storage_encrypted                   = true
  kms_key_id                          = aws_kms_key.rds_key.arn
  performance_insights_enabled        = true
  performance_insights_kms_key_id     = aws_kms_key.rds_key.arn
  parameter_group_name = aws_db_parameter_group.database.id
  enabled_cloudwatch_logs_exports = [
  "postgresql"]

  tags = merge(local.default_tags, {
    Name = "${local.res_prefix}-database"
  })
}

resource "aws_ssm_parameter" "rds_master_password" {
  name  = "/${local.res_prefix}/rds/master_password"
  type  = "SecureString"
  value = data.sops_file.secrets.data["rds_master_password"]
}
