source ~/jupyter-kubernetes-aws/aws/build-kubernetes.sh
source ~/jupyter-kubernetes-aws/aws/deploy-kubernetes.sh

while [ -z $VALID ]
do
  echo "
    CHECKING CLUSTER VALIDATION EVERY 10 seconds...  
  "
  VALID=$(\
    source ~/jupyter-kubernetes-aws/aws/validate-kubernetes-deployment.sh \
    | grep "is ready"
  )
  echo $VALID
  echo "
    CLUSTER IS STILL PENDING...
  "

  sleep 10
done

source ~/jupyter-kubernetes-aws/aws/validate-kubernetes-deployment.sh

source ~/jupyter-kubernetes-aws/kubernetes/container-network-interface/weave-net/encrypt-weave-net.sh
source ~/jupyter-kubernetes-aws/kubernetes/persistent-volume/aws-ebs/adjust-ebs-gp2-storage-class.sh 
source ~/jupyter-kubernetes-aws/kubernetes/persistent-volume/aws-efs/create-efs-aws.sh
source ~/jupyter-kubernetes-aws/kubernetes/persistent-volume/aws-efs/deploy-efs-provisioner.sh
