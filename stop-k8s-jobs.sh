#!/bin/bash
set -aeuo pipefail

# create the dotenv file if it doesn't exist
if [ ! -f .env ]; then
  cp .env.example .env
fi

source .env

kubectl delete job -n ${K8S_NAMESPACE} $(kubectl get jobs -n ${K8S_NAMESPACE} | grep ${JOB_NAME} | awk '{print $1}')
