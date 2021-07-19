#!/bin/bash
set -e
export WORKING_DIRECTORY=src/main/kubernetes
export DEPLOYMENT_FILE=$WORKING_DIRECTORY/deployment.yaml
export SERVICE_FILE=$WORKING_DIRECTORY/service.yaml
export DIRECTORY_OUTPUT=.k8s

envsubst < $DEPLOYMENT_FILE > $DIRECTORY_OUTPUT/deployment.yaml && \
cat $DIRECTORY_OUTPUT/deployment.yaml && \
envsubst < $SERVICE_FILE > $DIRECTORY_OUTPUT/service.yaml && \
cat $DIRECTORY_OUTPUT/service.yaml

exec "$@"
