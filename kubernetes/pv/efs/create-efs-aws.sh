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

