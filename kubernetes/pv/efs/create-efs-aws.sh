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

# Check to see if group already exists
EFS_SECURITY_GROUP_ID=$(\
  aws ec2 describe-security-groups \
    --region $AWS_REGION \
    --output $OUTPUT \
    --filters \
      Name=group-name,Values=efs.$NAME \
      Name=vpc-id,Values=$VPC_ID \
    | jq -r ".SecurityGroups[].GroupId"
)
if [[ ! -z "$EFS_SECURITY_GROUP_ID" ]]
then
  echo "efs.$NAME:     $EFS_SECURITY_GROUP_ID exists! Skipping to EFS creation"
else 
echo "
################################################################################
# CREATING EFS SECURITY GROUP
################################################################################
"
EFS_SECURITY_GROUP_ID=$(\
  aws ec2 create-security-group \
    --region $AWS_REGION \
    --output $OUTPUT \
    --description "Security group for efs" \
    --group-name efs.$NAME \
    --vpc-id $VPC_ID \
    | jq -r ".GroupId"
)
aws ec2 create-tags \
  --region $AWS_REGION \
  --output $OUTPUT \
  --resources $EFS_SECURITY_GROUP_ID \
  --tags Key=Name,Value=efs.$NAME
echo "efs.$NAME:     $EFS_SECURITY_GROUP_ID"

echo "
################################################################################
# AUTHORIZE NFS TRAFFIC TO SECURITY GROUPS
################################################################################
"
for GROUP_ID in $MASTERS_SECURITY_GROUP_ID $NODES_SECURITY_GROUP_ID
do
  aws ec2 authorize-security-group-ingress \
    --region $AWS_REGION \
    --output $OUTPUT \
    --group-id $GROUP_ID \
    --protocol tcp \
    --port 2049 \
    --source-group $EFS_SECURITY_GROUP_ID
  echo "NFS traffic authorized:$EFS_SECURITY_GROUP_ID (efs) -> $GROUP_ID (cluster)"
  aws ec2 authorize-security-group-ingress \
    --region $AWS_REGION \
    --output $OUTPUT \
    --group-id $EFS_SECURITY_GROUP_ID \
    --protocol tcp \
    --port 2049 \
    --source-group $GROUP_ID
  echo "NFS traffic authorized:$GROUP_ID (cluster) -> $EFS_SECURITY_GROUP_ID (efs)"
done
fi
echo "
################################################################################
# EFS - CREATE FILE SYSTEM
################################################################################
"
aws efs create-file-system \
  --region $AWS_REGION \
  --output $OUTPUT \
  --creation-token 123456789 \
  --performance-mode $EFS_PERFORMANCE_MODE \
  --encrypted \
  --throughput-mode $EFS_THROUGHPUT_MODE \
  --tags Key=Name,Value=efs.$NAME
