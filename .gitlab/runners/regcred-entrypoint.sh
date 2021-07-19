#!/bin/bash
set -e

mkdir -p .docker/
cat $DOCKER_CONF_JSON > .docker/config.json

export DOCKER_REGCRED="nexus-regcred"
# shellcheck disable=SC2126
# shellcheck disable=SC2155
export NEXUS_REGCRED_IS_EXIST=$(kubectl get secret "$DOCKER_REGCRED" -n "$KUBE_NAMESPACE" -o json --ignore-not-found=true | grep "$DOCKER_REGCRED" | wc -l)

if [ ${NEXUS_REGCRED_IS_EXIST} -eq 0 ]; then
  kubectl create secret generic "$DOCKER_REGCRED" --from-file=.dockerconfigjson=.docker/config.json --type=kubernetes.io/dockerconfigjson --namespace="$KUBE_NAMESPACE"
else
  echo "Docker Registry Credential was created"
fi

exec "$@"
