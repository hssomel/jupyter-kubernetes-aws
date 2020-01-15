#!/bin/bash

echo "
################################################################################
# INSTALL NGINX INGRESS CONTROLLER WITH AWS NLB
################################################################################
"
kubectl apply -f \
  ~/jupyter-kubernetes-aws/kubernetes/ingress-controller/nginx-ingress/nginx-ingress-aws-nlb-manifests.yaml
