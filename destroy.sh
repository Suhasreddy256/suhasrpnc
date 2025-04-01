#!/bin/sh

echo "Running terraform destroy, destroy stage in pipeline"

terraform destroy --auto-approve
