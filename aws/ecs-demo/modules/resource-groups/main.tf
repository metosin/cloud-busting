locals {
  workspace_name = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  module_name    = "resource-groups"
  res_prefix     = "${var.prefix}${local.workspace_name}"
  default_tags   = {
    Resprefix = local.res_prefix
    Prefix    = var.prefix
    Workspace = terraform.workspace
    Module    = local.module_name
    Terraform = "true"
  }
}

module "rg_resprefix" {
  source    = "./resource-group"
  rg_name   = "${local.res_prefix}-resprefix"
  tag_key   = "Resprefix"
  tag_value = local.res_prefix
}

module "rg_prefix" {
  source    = "./resource-group"
  rg_name   = "${local.res_prefix}-prefix"
  tag_key   = "Prefix"
  tag_value = var.prefix
}

module "rg_terraform" {
  source    = "./resource-group"
  rg_name   = "${local.res_prefix}-terraform"
  tag_key   = "Terraform"
  tag_value = "true"
}

module "rg_module_bastion" {
  source    = "./resource-group"
  rg_name   = "${local.res_prefix}-bastion"
  tag_key   = "Module"
  tag_value = data.terraform_remote_state.bastion.outputs.module_name
}

module "rg_module_ecr" {
  source    = "./resource-group"
  rg_name   = "${local.res_prefix}-ecr"
  tag_key   = "Module"
  tag_value = data.terraform_remote_state.ecr.outputs.module_name
}

module "rg_module_ecs" {
  source    = "./resource-group"
  rg_name   = "${local.res_prefix}-ecs"
  tag_key   = "Module"
  tag_value = data.terraform_remote_state.ecs.outputs.module_name
}

module "rg_module_network" {
  source    = "./resource-group"
  rg_name   = "${local.res_prefix}-network"
  tag_key   = "Module"
  tag_value = data.terraform_remote_state.network.outputs.module_name
}

module "rg_module_rds" {
  source    = "./resource-group"
  rg_name   = "${local.res_prefix}-rds"
  tag_key   = "Module"
  tag_value = data.terraform_remote_state.rds.outputs.module_name
}

