#!/usr/bin/env bash

set -eu -o pipefail

# Helper script for applying all modules in dependency order and building the application

apply_module() {
    local MODULE=$1
    echo "Applying $MODULE"
    pushd $MODULE > /dev/null
    source ../../../tools/terraform-init
    terraform apply -auto-approve
    popd > /dev/null
}

build_application() {
    pushd ../application > /dev/null
    ./build.sh
    popd > /dev/null
}

apply_module network
apply_module ecr
apply_module rds

# Building the app creates a docker image tagged with the short Git SHA
build_application
# We specify the Git SHA also for deploy
export TF_VAR_image_tag=$(git rev-parse --short HEAD)
apply_module ecs
unset TF_VAR_image_tag

# For lookup our public IP to allow access to the bastion host
PUBLIC_IP=$(curl -s ifconfig.co)
export TF_VAR_developer_ips=\[\""$PUBLIC_IP/32"\"\]
apply_module bastion
unset TF_VAR_developer_ips

apply_module resource-groups
