# Install kubernetes components in one shot

source ./.kubernetes.config

kubectl create namespace efs-provisioner

helm install efs-provisioner ./efs-provisioner \
    --set global.deployEnv=$DEPLOY_ENV \
    --set efsProvisioner.efsFileSystemId=$EFS_FILE_SYSTEM_ID \
    --set efsProvisioner.awsRegion=$AWS_REGION \
    --set efsProvisioner.provisionerName=$PROVISIONER_NAME \
    --namespace $NAMESPACE
