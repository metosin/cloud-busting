#!/usr/bin/env bash

set -eu -o pipefail

pushd ../modules/ecr > /dev/null
ECR_REPO_URL=$(terraform output backend_repository_url)
popd > /dev/null

echo $ECR_REPO_URL

GIT_SHA=$(git rev-parse --short HEAD)
clj -A:pack \
    -m mach.pack.alpha.jib \
    --base-image gcr.io/distroless/java:11 \
    --image-name $ECR_REPO_URL:$GIT_SHA \
    --image-type registry \
    -m clj-ecs.core
