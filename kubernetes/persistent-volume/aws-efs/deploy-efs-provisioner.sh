source ~/jupyter-kubernetes-aws/.config

echo "
################################################################################
# Find EFS File system ID
################################################################################
"
EFS_FILE_SYSTEM_ID=$(\
  aws efs describe-file-systems \
    --region $AWS_REGION \
    --output $OUTPUT \
    --creation-token $EFS_CREATION_TOKEN \
    | jq -r ".FileSystems[0].FileSystemId" \
)
echo "efs.$NAME found: $EFS_FILE_SYSTEM_ID"

echo "
################################################################################
# Create efs-provisioner namespace
################################################################################
"
kubectl create namespace efs-provisioner

echo "
################################################################################
# Install using helm
################################################################################
"
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm install stable/efs-provisioner \
  --generate-name \
  --set efsProvisioner.efsFileSystemId=$EFS_FILE_SYSTEM_ID \
  --set efsProvisioner.awsRegion=$AWS_REGION \
  --namespace efs-provisioner

echo "
################################################################################
# Make aws-efs the default storageclass
################################################################################
"
kubectl patch storageclass aws-efs \
  -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
