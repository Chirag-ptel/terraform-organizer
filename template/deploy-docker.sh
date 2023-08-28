#!/bin/bash

# Fail fast
set -e

# This is the order of arguments
image=$1
aws_ecr_repository_url_with_tag=$2
aws_region=$3

if [ "$aws_region" != "" ]; then
  aws_extra_flags="--region $aws_region"
else
  aws_extra_flags=""
fi

# Check that aws is installed
which aws > /dev/null || { echo 'ERROR: aws-cli is not installed' ; exit 1; }

# Check that docker is installed and running
which docker > /dev/null && docker ps > /dev/null || { echo 'ERROR: docker is not running' ; exit 1; }

# Connect aws and docker
aws ecr get-login-password $aws_extra_flags | docker login --username AWS --password-stdin $aws_ecr_repository_url_with_tag

echo "Building $aws_ecr_repository_url_with_tag from Dockerfile"

# Build image
docker build -t $image .

# tag image
docker tag $image $aws_ecr_repository_url_with_tag

# Push image
docker push $aws_ecr_repository_url_with_tag
