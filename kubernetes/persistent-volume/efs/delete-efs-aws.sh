source ~/jupyter-kubernetes-aws/.config

echo "
################################################################################
# OBTAINING CLUSTER VPC & SECURITY GROUP INFORMATION
################################################################################
"
VPC_ID=$(\
  aws ec2 describe-vpcs \
    --region $AWS_REGION \
    --output $OUTPUT \
    --filters Name=tag:Name,Values=$NAME \
    | jq -r ".Vpcs[0].VpcId" \
)
echo "$NAME:         $VPC_ID"

MASTERS_SECURITY_GROUP_ID=$(\
  aws ec2 describe-security-groups \
    --region $AWS_REGION \
    --output $OUTPUT \
    --filters \
      Name=group-name,Values=masters.$NAME \
      Name=vpc-id,Values=$VPC_ID \
    | jq -r ".SecurityGroups[].GroupId" \
)
echo "masters.$NAME: $MASTERS_SECURITY_GROUP_ID"

NODES_SECURITY_GROUP_ID=$(\
  aws ec2 describe-security-groups \
    --region $AWS_REGION \
    --output $OUTPUT \
    --filters \
      Name=group-name,Values=nodes.$NAME \
      Name=vpc-id,Values=$VPC_ID \
    | jq -r ".SecurityGroups[].GroupId" \
)
echo "nodes.$NAME:   $NODES_SECURITY_GROUP_ID"

EFS_SECURITY_GROUP_ID=$(\
  aws ec2 describe-security-groups \
    --region $AWS_REGION \
    --output $OUTPUT \
    --filters \
      Name=group-name,Values=efs.$NAME \
      Name=vpc-id,Values=$VPC_ID \
    | jq -r ".SecurityGroups[].GroupId" \
)
echo "efs.$NAME:     $NODES_SECURITY_GROUP_ID"

echo "
################################################################################
# REVOKE NFS TRAFFIC TO SECURITY GROUPS
################################################################################
"
for GROUP_ID in $MASTERS_SECURITY_GROUP_ID $NODES_SECURITY_GROUP_ID
do
  aws ec2 revoke-security-group-ingress \
    --region $AWS_REGION \
    --output $OUTPUT \
    --group-id $GROUP_ID \
    --protocol tcp \
    --port 2049 \
    --source-group $EFS_SECURITY_GROUP_ID
  echo "NFS traffic revoked:$EFS_SECURITY_GROUP_ID (efs) -> $GROUP_ID (cluster)"
  aws ec2 revoke-security-group-ingress \
    --region $AWS_REGION \
    --output $OUTPUT \
    --group-id $EFS_SECURITY_GROUP_ID \
    --protocol tcp \
    --port 2049 \
    --source-group $GROUP_ID
  echo "NFS traffic revoked:$GROUP_ID (cluster) -> $EFS_SECURITY_GROUP_ID (efs)"
done

echo "
################################################################################
# EFS - DESCRIBE FILE SYSTEM
################################################################################
"
EFS_FILE_SYSTEM_ID=$(\
  aws efs describe-file-systems \
    --region $AWS_REGION \
    --output $OUTPUT \
    --creation-token $EFS_CREATION_TOKEN \
    | jq -r ".FileSystems[0].FileSystemId" \
)
echo "efs.$NAME:     $EFS_FILE_SYSTEM_ID"
MOUNT_TARGET_IDS=$(\
  aws efs describe-mount-targets \
    --region $AWS_REGION \
    --output $OUTPUT \
    --file-system-id $EFS_FILE_SYSTEM_ID \
    | jq -r ".MountTargets[].MountTargetId" \
)
echo "$EFS_FILE_SYSTEM_ID has the following mount targets::"
echo $MOUNT_TARGET_IDS

echo "
################################################################################
# EFS - DELETE MOUNT TARGETS IN VPC
################################################################################
"
for MOUNT_TARGET_ID in $MOUNT_TARGET_IDS
do
  aws efs delete-mount-target \
    --region $AWS_REGION \
    --output $OUTPUT \
    --mount-target-id $MOUNT_TARGET_ID
  echo "mount target:  $MOUNT_TARGET_ID deletion started"
done

while [[ ! -z $MOUNT_TARGET_IDS ]] 
do
  MOUNT_TARGET_IDS=$(\
    aws efs describe-mount-targets \
      --region $AWS_REGION \
      --output $OUTPUT \
      --file-system-id $EFS_FILE_SYSTEM_ID \
      | jq -r ".MountTargets[].MountTargetId" \
  )
  echo "Waiting for mount targets to be deleted..."
  sleep 1
done

echo "Mount targets have been deleted"


echo "
################################################################################
# EFS - DELETE FILE SYSTEM
################################################################################
"
LIFE_CYCLE_STATE=$(
  aws efs describe-file-systems \
    --region $AWS_REGION \
    --output $OUTPUT \
    --file-system-id $EFS_FILE_SYSTEM_ID \
    | jq -r ".FileSystems[0].LifeCycleState" \
)
while [ $LIFE_CYCLE_STATE != "available" ]
do
  echo "Waiting for $EFS_FILE_SYSTEM_ID to become available before deletion..."
  LIFE_CYCLE_STATE=$(
    aws efs describe-file-systems \
      --region $AWS_REGION \
      --output $OUTPUT \
      --file-system-id $EFS_FILE_SYSTEM_ID \
      | jq -r ".FileSystems[0].LifeCycleState" \
  )
  sleep 1
done
    aws efs delete-file-system \
      --region $AWS_REGION \
      --output $OUTPUT \
      --file-system-id $EFS_FILE_SYSTEM_ID \
      | grep -i "error" 
echo "efs.$NAME:     $EFS_FILE_SYSTEM_ID deleted"

echo "
################################################################################
# EFS - DELETE ASSOCIATED SECURITY GROUP
################################################################################
"
aws ec2 delete-security-group \
  --region $AWS_REGION \
  --output $OUTPUT \
  --group-id $EFS_SECURITY_GROUP_ID

echo "efs.$NAME:     $EFS_SECURITY_GROUP_ID deleted"
