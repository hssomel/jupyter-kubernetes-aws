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
    | jq -r ".Vpcs[0].VpcId"
)
echo "$NAME:         $VPC_ID"

MASTERS_SECURITY_GROUP_ID=$(\
  aws ec2 describe-security-groups \
    --region $AWS_REGION \
    --output $OUTPUT \
    --filters \
      Name=group-name,Values=masters.$NAME \
      Name=vpc-id,Values=$VPC_ID \
    | jq -r ".SecurityGroups[].GroupId"
)
echo "masters.$NAME: $MASTERS_SECURITY_GROUP_ID"

NODES_SECURITY_GROUP_ID=$(\
  aws ec2 describe-security-groups \
    --region $AWS_REGION \
    --output $OUTPUT \
    --filters \
      Name=group-name,Values=nodes.$NAME \
      Name=vpc-id,Values=$VPC_ID \
    | jq -r ".SecurityGroups[].GroupId"
)
echo "nodes.$NAME:   $NODES_SECURITY_GROUP_ID"

EFS_SECURITY_GROUP_ID=$(\
  aws ec2 describe-security-groups \
    --region $AWS_REGION \
    --output $OUTPUT \
    --filters \
      Name=group-name,Values=efs.$NAME \
      Name=vpc-id,Values=$VPC_ID \
    | jq -r ".SecurityGroups[].GroupId"
)


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
  echo "NFS traffic authorized:$EFS_SECURITY_GROUP_ID (efs) -> $GROUP_ID (cluster)"
  aws ec2 revoke-security-group-ingress \
    --region $AWS_REGION \
    --output $OUTPUT \
    --group-id $EFS_SECURITY_GROUP_ID \
    --protocol tcp \
    --port 2049 \
    --source-group $GROUP_ID
  echo "NFS traffic authorized:$GROUP_ID (cluster) -> $EFS_SECURITY_GROUP_ID (efs)"
done


echo "
################################################################################
# EFS - DELETE FILE SYSTEM
################################################################################
"
EFS_FILE_SYSTEM_ID=$(\
  aws efs describe-file-systems \
    --region $AWS_REGION \
    --output $OUTPUT \
    --creation-token $EFS_CREATION_TOKEN \
    | jq -r ".FileSystemId" \
)
echo "efs.$NAME:     $EFS_FILE_SYSTEM_ID deleted"

LIFE_CYCLE_STATE=placeholder

while [ $LIFE_CYCLE_STATE != "available" ]
do
  echo "Waiting for $EFS_FILE_SYSTEM_ID to become available..."
  LIFE_CYCLE_STATE=$(
    aws efs describe-file-systems \
      --region $AWS_REGION \
      --output $OUTPUT \
      --file-system-id $EFS_FILE_SYSTEM_ID \
      | jq -r ".FileSystems[0].LifeCycleState"
  )
  sleep 1
done

