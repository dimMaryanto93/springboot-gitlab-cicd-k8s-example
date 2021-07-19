#!/bin/bash
set -e
export WORKING_DIRECTORY=src/main/kubernetes
export DEPLOYMENT_FILE=$WORKING_DIRECTORY/deployment.yaml
export SERVICE_FILE=$WORKING_DIRECTORY/service.yaml

envsubst < DEPLOYMENT_FILE > deployment.yaml && \
cat deployment.yaml
envsubst < SERVICE_FILE > service.yaml && \
cat service.yaml

exec "$@"
