# Use after setting up weave CNI if encryption on the Pod network is desired

# To store encryption password as key-value pair in a k8s secret
SECRET_NAME=weave-encryption-password # k8s object metadata
SECRET_KEY=weave-encryption-password
SECRET_VALUE=$(openssl rand -hex 128) # this randomly generated 128 bytes password gets base64 encoded when sent off with kubectl

# Put weave-encryption-password into k8s secret
kubectl create secret generic $SECRET_NAME \
    --from-literal "${SECRET_KEY}=${SECRET_VALUE}" \
    --namespace kube-system

# Inject the value of this secret into the env variable WEAVE_PASSWORD for weave-net pods
kubectl patch daemonset/weave-net \
    --type json \
    -p  '[ { "op": "add", "path": "/spec/template/spec/containers/0/env/0", "value": { "name": "WEAVE_PASSWORD", "valueFrom": { "secretKeyRef": { "key": "'${SECRET_KEY}'", "name": "'${SECRET_NAME}'" } } } } ]' \
    --namespace kube-system
