#!/bin/bash

NAMSPACE=$1

echo "
################################################################################
# INSTALL OR UPGRADE JUPYTERHUB  WITH HELM
################################################################################
"

CHECK_NAMESPACE=$( \
  kubectl get namespaces | grep "^${NAMESPACE} " \
)

if [[ -z $CHECK_NAMESPACE ]]
then
  kubectl create namespace $NAMESPACE
fi

RELEASE=jupyterhub-dev-$NAMESPACE

helm upgrade $RELEASE \
  ~/jupyter-kubernetes-aws/jupyterhub-kubernetes/jupyterhub \
  --namespace $NAMESPACE \
  --devel \
  --atomic \
  --values ~/jupyter-kubernetes-aws/jupyterhub-kubernetes/.values.yaml \
  --install
