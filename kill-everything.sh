#!/bin/bash
#kubectl delete pvc --all --all-namespaces
#kubectl delete ns efs-provisioner
source ~/jupyter-kubernetes-aws/kubernetes/persistent-volume/aws-efs/delete-efs-aws.sh
source ~/jupyter-kubernetes-aws/aws/kill-kubernetes.sh


