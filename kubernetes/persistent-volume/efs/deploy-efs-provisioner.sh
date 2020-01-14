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
# Delete gp2 and default storage classes from kops
################################################################################
"
kubectl delete storageclass default
kubectl celete storageclass gp2

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

