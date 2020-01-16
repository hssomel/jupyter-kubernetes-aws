#!/bin/bash
source ~/jupyter-kubernetes-aws/.config

echo "
################################################################################
# OBTAINING CLUSTER VPC & SECURITY GROUP INFORMATION
################################################################################
"
VPC_ID=$( \
  aws ec2 describe-vpcs \
    --region $AWS_REGION \
    --output $OUTPUT \
    --filters Name=tag:Name,Values=$NAME \
    | jq -r ".Vpcs[0].VpcId" \
)
echo "$NAME:         $VPC_ID"


NODES_SECURITY_GROUP_ID=$( \
  aws ec2 describe-security-groups \
    --region $AWS_REGION \
    --output $OUTPUT \
    --filters \
      Name=group-name,Values=nodes.$NAME \
      Name=vpc-id,Values=$VPC_ID \
    | jq -r ".SecurityGroups[].GroupId" \
)
echo "nodes.$NAME:   $NODES_SECURITY_GROUP_ID"

echo "
################################################################################
# AUTHORIZE PUBLIC TLS NODEPORT TRAFFIC
################################################################################
"
for GROUP_ID in $NODES_SECURITY_GROUP_ID
do
  aws ec2 authorize-security-group-ingress \
    --region $AWS_REGION \
    --output $OUTPUT \
    --cidr "0.0.0.0/0" \
    --group-id $GROUP_ID \
    --protocol tcp \
    --port "30000-32767"
  echo "Public TLS over NodePorts authorized for $GROUP_ID"
done
