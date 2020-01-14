#!/bin/bash
echo "
################################################################################
# ENCRYPT WEAVE NET CNI
################################################################################
"
kubectl create secret generic weave-net-encryption-password \
  --from-literal WEAVE_PASSWORD=$(openssl rand -hex 128) \
  --namespace kube-system

kubectl set env daemonset/weave-net \
  --keys WEAVE_PASSWORD \
  --from secret/weave-net-encryption-password \
  --containers weave \
  --namespace kube-system
