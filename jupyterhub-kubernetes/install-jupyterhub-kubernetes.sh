#!/bin/bash

echo "
################################################################################
# INSTALL OR UPGRADE JUPYTERHUB  WITH HELM
################################################################################
"

NAMESPACE=$( \
  kubectl get namespaces | grep "^jupyterhub " \
)

if [[ -z $NAMESPACE ]]
then
  kubectl create namespace jupyterhub
fi

RELEASE=jupyterhub-dev

helm upgrade $RELEASE \
  ~/jupyter-kubernetes-aws/jupyterhub-kubernetes/jupyterhub \
  --namespace jupyterhub \
  --devel \
  --atomic \
  --values ~/jupyter-kubernetes-aws/jupyterhub-kubernetes/.values.yaml \
  --install
