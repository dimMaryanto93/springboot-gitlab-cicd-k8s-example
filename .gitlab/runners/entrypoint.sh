#!/bin/bash
set -e

eval "echo \"$(cat deployment.yaml)\" > src/main/kubernetes/deployment.yaml"
eval "echo \"$(cat deployment.yaml)\" > src/main/kubernetes/service.yaml"

exec "$@"
