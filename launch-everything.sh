#!/bin/bash
echo "
################################################################################
# MASTER 'ON-SWITCH' SCRIPT
################################################################################
"

source \
  ~/jupyter-kubernetes-aws/.config
source \
  ~/jupyter-kubernetes-aws/aws/build-kubernetes.sh
source \
  ~/jupyter-kubernetes-aws/aws/deploy-kubernetes.sh

SUCCESS_COUNT=0
while [[ $SUCCESS_COUNT -lt 4 ]]
do
  echo "Performing cluster validation checkpoints every 30 seconds..."
  sleep 30
  VALID=$( \
    source \
      ~/jupyter-kubernetes-aws/aws/validate-kubernetes-deployment.sh \
      | grep "Your cluster $NAME is ready" \
  )
  if [[ $VALID == "Your cluster $NAME is ready" ]]
  then
    ((SUCCESS_COUNT++))
    echo "Cluster showing ready at checkpoint #$SUCCESS_COUNT"
    echo "Waiting for 4 successful consecutive checkpoints..."
  else
    SUCCESS_COUNT=0
    echo "Cluster not ready..."
  fi
done
echo "Cluster is ready for use..."
source \
  ~/jupyter-kubernetes-aws/aws/validate-kubernetes-deployment.sh

# Container Network Interface Security
source \
  ~/jupyter-kubernetes-aws/kubernetes/container-network-interface/weave-net/encrypt-weave-net.sh

# PersistentVolumes and PersistentVolumeClaims
source \
  ~/jupyter-kubernetes-aws/kubernetes/persistent-volume/aws-ebs/adjust-ebs-gp2-storage-class.sh 
source \
  ~/jupyter-kubernetes-aws/kubernetes/persistent-volume/aws-efs/create-efs-aws.sh
source \
  ~/jupyter-kubernetes-aws/kubernetes/persistent-volume/aws-efs/deploy-efs-provisioner.sh

# Ingress
source \
  ~/jupyter-kubernetes-aws/kubernetes/ingress-controller/install-nginx-ingress-controller.sh
