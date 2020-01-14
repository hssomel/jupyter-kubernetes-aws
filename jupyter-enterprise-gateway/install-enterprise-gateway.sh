#!/bin/bash

kubectl create namespace enterprise-gateway

helm install \
  ~/jupyter-kubernetes-aws/jupyter-enterprise-gateway/enterprise-gateway \
  --generate-name \
  --namespace enterprise-gateway \
  --devel \
  --values ~/jupyter-kubernetes-aws/jupyter-enterprise-gateway/.values.json
