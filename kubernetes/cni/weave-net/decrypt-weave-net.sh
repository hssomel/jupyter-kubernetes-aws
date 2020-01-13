echo "
################################################################################
# DECRYPT WEAVE NET CNI
################################################################################
"
kubectl set env daemonset/weave-net \
  --containers weave \
  WEAVE_PASSWORD- \
  --namespace kube-system

kubectl delete secret weave-net-encryption-password \
  --namespace kube-system
