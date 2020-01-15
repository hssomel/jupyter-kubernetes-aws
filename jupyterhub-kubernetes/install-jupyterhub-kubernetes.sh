#!/bin/bash

kubectl create namespace jupyterhub

RELEASE=jupyterhub-dev

helm upgrade $RELEASE \
  ~/jupyter-kubernetes-aws/jupyterhub-kubernetes/jupyterhub \
  --namespace jupyterhub \
  --devel \
  --atomic \
  --values ~/jupyter-kubernetes-aws/jupyterhub-kubernetes/.values.yaml \
  --install
