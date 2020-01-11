# Generates your yaml manifests using ./.efs.provisioner.config and puts them in ./efs-provisioner.yaml

# after this, use 
kubectl apply -f efs-provisioner.yaml 

# and this will be created:
#    namespace/efs-provisioner created
#    clusterrole.rbac.authorization.k8s.io/efs-provisioner-runner created
#    clusterrolebinding.rbac.authorization.k8s.io/run-efs-provisioner created
#    role.rbac.authorization.k8s.io/leader-locking-efs-provisioner created
#    rolebinding.rbac.authorization.k8s.io/leader-locking-efs-provisioner created
#    configmap/efs-provisioner created
#    deployment.extensions/efs-provisioner created
#    storageclass.storage.k8s.io/aws-efs created

source ./.efs-provisioner.config

echo "
kind: Namespace
apiVersion: v1
metadata:
  annotations:
  labels:
    app.kubernetes.io/name: efs-provisioner
    app.kubernetes.io/part-of: efs-provisioner
    app.kubernetes.io/component: storage
  name: ${EFS_PROVISIONER_NAMESPACE}

---

kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  labels:
    app.kubernetes.io/name: efs-provisioner
    app.kubernetes.io/part-of: efs-provisioner
    app.kubernetes.io/component: storage
  name: efs-provisioner-runner
rules:
- apiGroups: ['']
  resources: ['persistentvolumes']
  verbs: ['get', 'list', 'watch', 'create', 'delete']
- apiGroups: ['']
  resources: ['persistentvolumeclaims']
  verbs: ['get', 'list', 'watch', 'update']
- apiGroups: ['storage.k8s.io']
  resources: ['storageclasses']
  verbs: ['get', 'list', 'watch']
- apiGroups: ['']
  resources: ['events']
  verbs: ['create', 'update', 'patch']

---

kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  labels:
    app.kubernetes.io/name: efs-provisioner
    app.kubernetes.io/part-of: efs-provisioner
    app.kubernetes.io/component: storage
  name: run-efs-provisioner
subjects:
- kind: ServiceAccount
  name: efs-provisioner
  namespace: ${EFS_PROVISIONER_NAMESPACE}
roleRef:
  kind: ClusterRole
  name: efs-provisioner-runner
  apiGroup: rbac.authorization.k8s.io

---

kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  labels:
    app.kubernetes.io/name: efs-provisioner
    app.kubernetes.io/part-of: efs-provisioner
    app.kubernetes.io/component: storage
  name: leader-locking-efs-provisioner
  namespace: ${EFS_PROVISIONER_NAMESPACE}
rules:
- apiGroups: ['']
  resources: ['endpoints']
  verbs: ['get', 'list', 'watch', 'create', 'update', 'patch']

---

kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  labels:
    app.kubernetes.io/name: efs-provisioner
    app.kubernetes.io/part-of: efs-provisioner
    app.kubernetes.io/component: storage
  name: leader-locking-efs-provisioner
  namespace: ${EFS_PROVISIONER_NAMESPACE}
subjects:
- kind: ServiceAccount
  name: efs-provisioner
  namespace: ${EFS_PROVISIONER_NAMESPACE}
roleRef:
  kind: Role
  name: leader-locking-efs-provisioner
  apiGroup: rbac.authorization.k8s.io

---

kind: ConfigMap
apiVersion: v1
metadata:
  labels:
    app.kubernetes.io/name: efs-provisioner
    app.kubernetes.io/part-of: efs-provisioner
    app.kubernetes.io/component: storage
  name: efs-provisioner
  namespace: ${EFS_PROVISIONER_NAMESPACE}
data:
  file.system.id: ${EFS_FILE_SYSTEM_ID}
  aws.region: ${EFS_REGION}
  provisioner.name: ${DNS_NAME}/aws-efs
  dns.name: ${DNS_NAME}

---

kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  labels:
    app.kubernetes.io/name: efs-provisioner
    app.kubernetes.io/part-of: efs-provisioner
    app.kubernetes.io/component: storage
  name: efs-provisioner
  namespace: ${EFS_PROVISIONER_NAMESPACE}
spec:
  replicas: 1
  strategy:
    type: Recreate 
  template:
    metadata:
      labels:
        app.kubernetes.io/name: efs-provisioner
        app.kubernetes.io/part-of: efs-provisioner
        app.kubernetes.io/component: storage
    spec:
      containers:
      - name: efs-provisioner
        image: quay.io/external_storage/efs-provisioner:latest
        env:
        - name: FILE_SYSTEM_ID
          valueFrom:
            configMapKeyRef:
              name: efs-provisioner
              key: file.system.id
        - name: AWS_REGION
          valueFrom:
            configMapKeyRef:
              name: efs-provisioner
              key: aws.region
        - name: DNS_NAME
          valueFrom:
            configMapKeyRef:
              name: efs-provisioner
              key: dns.name
              optional: true
        - name: PROVISIONER_NAME
          valueFrom:
            configMapKeyRef:
              name: efs-provisioner
              key: provisioner.name
        volumeMounts:
        - name: pv-volume
          mountPath: /persistentvolumes
      volumes:
      - name: pv-volume
        nfs:
          server: ${EFS_FILE_SYSTEM_ID}.efs.${EFS_REGION}.amazonaws.com
          path: /

---

kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  annotations:
    storageclass.beta.kubernetes.io/is-default-class: 'true'
  labels:
    app.kubernetes.io/name: efs-provisioner
    app.kubernetes.io/part-of: efs-provisioner
    app.kubernetes.io/component: storage
  name: aws-efs
provisioner: ${DNS_NAME}/aws-efs
reclaimPolicy: Delete
volumeBindingMode: Immediate

---

####### Can be used to test PVC creation

#kind: PersistentVolumeClaim
#apiVersion: v1
#metadata:
#  name: efs
#  annotations:
#    volume.beta.kubernetes.io/storage-class: 'aws-efs'
#spec:
#  accessModes:
#    - ReadWriteMany
#  resources:
#    requests:
#      storage: 1Mi
#
#---" > efs-provisioner.yaml

