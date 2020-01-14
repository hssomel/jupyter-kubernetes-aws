#!/bin/bash
echo "
################################################################################
# MAKE AWS EBS STORAGECLASS NON-DEFAULT
################################################################################
"
kubectl delete storageclass default
kubectl delete storageclass gp2
kubectl apply -f \
  ~/jupyter-kubernetes-aws/kubernetes/persistent-volume/aws-ebs/ebs-gp2-storage-class.yaml
