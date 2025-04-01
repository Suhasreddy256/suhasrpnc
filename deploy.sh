#!/bin/sh

echo "Running terraform init, init stage in pipeline"
terraform init

echo "Running terraform validate, validate stage in pipeline"
terraform validate

echo "Running terraform plan, plan stage in pipeline"
terraform plan

echo "Running terraform apply, apply stage in pipeline"
terraform apply --auto-approve
