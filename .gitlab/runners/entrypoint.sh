#!/bin/bash
set -e

export DEPLOYMENT_FILE=src/main/kubernetes/deployment.yaml
export SERVICE_FILE=src/main/kubernetes/service.yaml

eval "echo \"$(cat ${DEPLOYMENT_FILE})\" > ${DEPLOYMENT_FILE}"
eval "echo \"$(cat ${SERVICE_FILE})\" > ${SERVICE_FILE}"

exec "$@"
