#!/usr/bin/env bash

# Helper script for destroying all modules in dependency order

destroy_module() {
    local MODULE=$1
    echo "Destroying $MODULE"
    pushd $MODULE > /dev/null
    source ../../../tools/terraform-init
    terraform destroy -auto-approve
    popd > /dev/null
}

destroy_module resource-groups

# Input variables need to be always defined, even though we would not need them in the destroy phase
export TF_VAR_developer_ips='[]'
destroy_module bastion
unset TF_VAR_developer_ips

export TF_VAR_image_tag=W
destroy_module ecs
unset TF_VAR_image_tag

destroy_module rds
destroy_module ecr
destroy_module network
destroy_module common
