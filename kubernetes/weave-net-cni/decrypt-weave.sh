# Use after setting up weave CNI if encryption on the Pod network is desired

SECRET_NAME=weave-encryption-password # was set by ./encrypt-weave.sh

CURRENT_ENV_VAR_AT_INDEX_0=$(\
kubectl get daemonset/weave-net \
    --output jsonpath='{.spec.template.spec.containers[0].env[0].name}'\
    --namespace kube-system \
)

# Safety Check to not mess up config
if [ $CURRENT_ENV_VAR_AT_INDEX_0 != "WEAVE_PASSWORD" ]; then 
    echo "Please check daemonset/weave-net in namespace kube-system manually and delete the WEAVE_PASSWORD env variable if it exists"
    echo "This daemonset's environment variable list order is not as expected." 
    echo "./encrpyt-weave.sh would have injected it as the first variable in the list/array" 
    exit 1
else
    kubectl patch daemonset/weave-net \
        --type json \
	-p '[ { "op": "remove", "path": "/spec/template/spec/containers/0/env/0"} ]' \
	--namespace kube-system
    kubectl delete secret $SECRET_NAME \
        --namespace kube-system
fi

