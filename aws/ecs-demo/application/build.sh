#!/usr/bin/env bash

set -eu -o pipefail

pushd ../modules/ecr > /dev/null
ECR_REPO_URL=$(terraform output backend_repository_url)
popd > /dev/null

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --out text)
aws ecr get-login-password | docker login --username AWS --password-stdin https://$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com

echo $ECR_REPO_URL

GIT_SHA=$(git rev-parse --short HEAD)
clojure -A:pack \
        -m mach.pack.alpha.jib \
        --base-image gcr.io/distroless/java:11 \
        --image-name $ECR_REPO_URL:$GIT_SHA \
        --image-type registry \
        -m clj-ecs.core
