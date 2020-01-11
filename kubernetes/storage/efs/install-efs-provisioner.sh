# Repeatable with mutiple EFS's for convenience

source ./.efs-provisioner.config

helm install ./efs-provisioner \
    --set global.deployEnv=$DEPLOY_ENV \
    --set efsProvisioner.efsFileSystemId=$EFS_FILE_SYSTEM_ID \
    --set efsProvisioner.awsRegion=$AWS_REGION \
    --set efsProvisioner.provisionerName=$PROVISIONER_NAME
