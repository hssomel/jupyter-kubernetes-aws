source ./.kubernetes.config


EFS_FILE_SYSTEM_ID=fs-9a4c541b

VPC_ID=$(\
  aws ec2 describe-vpcs \
    --region=$AWS_REGION
    --filters Name=tag:Name,Values=$KUBERNETES_CLUSTER_NAME \
    | jq -r ".Vpcs[0].VpcId"
)

echo $VPC_ID

aws ec2 create-security-group --description "Security group for efs in kubernetes cluster" --groupname "efs.$KUBERNETES_CLUSTER_NAME"

SUBNET_IDS=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=vpc-038d63505a2be1abb | jq -r ".Subnets[].SubnetId")

echo $SUBNET_IDS

for SUBNET_ID in $SUBNET_IDS
do
aws efs create-mount-target \
  --file-system-id $EFS_FILE_SYSTEM_ID \
  --subnet-id $SUBNET_ID \
  --security-groups
done

