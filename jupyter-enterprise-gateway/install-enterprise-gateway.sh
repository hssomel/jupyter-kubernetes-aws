#!/bin/bash

echo "
################################################################################
# INSTALL OR UPGRADE ENTERPRISE GATEWAY WITH HELM
################################################################################
"

NAMESPACE=$( \
  kubectl get namespaces | grep "enterprise-gateway" \
)

if [[ -z $NAMESPACE ]]
then
  kubectl create namespace enterprise-gateway
fi

RELEASE=enterprise-gateway-dev

helm upgrade $RELEASE \
  ~/jupyter-kubernetes-aws/jupyter-enterprise-gateway/enterprise-gateway \
  --install \
  --atomic \
  --namespace enterprise-gateway \
  --devel \
  --values ~/jupyter-kubernetes-aws/jupyter-enterprise-gateway/.values.yaml
