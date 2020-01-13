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

