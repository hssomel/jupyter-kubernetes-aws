#/bin/bash

NETWORK_SECURITY=placeholder

source ./.kops.config #Config shared between private/public clusters

if [[ $NETWORK_SECURITY == "public" ]]; then
       # --api-loadbalancer-type "public"  <-- took out for single master node dev environment
    kops create cluster $NAME \
        --state $KOPS_STATE_STORE \
        --admin-access "0.0.0.0/0" \
        --associate-public-ip="true" \
        --authorization "RBAC" \
        --channel "stable" \
        --cloud $CLOUD \
        --cloud-labels $CLOUD_LABELS \
        --dns "public" \
        --encrypt-etcd-storage \
        --master-count $MASTER_COUNT \
        --master-size $MASTER_SIZE \
        --master-tenancy $NODE_TENANCY \
        --master-volume-size $NODE_VOLUME_SIZE \
        --master-zones $NODE_ZONES \
        --network-cidr $NETWORK_CIDR \
        --networking $CNI \
        --node-count $WORKER_COUNT \
        --node-size $WORKER_SIZE \
        --node-tenancy $NODE_TENANCY \
        --node-volume-size $NODE_VOLUME_SIZE \
        --ssh-access "0.0.0.0/0" \
        --ssh-public-key $SSH_PUB_KEY_DIR \
        --topology "public" \
        --zones $NODE_ZONES 
#        --output yaml \
#        --dry-run
elif [[ $NETWORK_SECURITY == "private" ]]; then
    kops create cluster $NAME \
        --state $KOPS_STATE_STORE \
        --admin-access $NETWORK_CIDR \
        --api-loadbalancer-type "internal" \
        --associate-public-ip="false" \
        --authorization "RBAC" \
        --bastion \
        --channel "stable" \
        --cloud $CLOUD \
        --cloud-labels $CLOUD_LABELS \
        --dns "private" \
        --encrypt-etcd-storage \
        --master-count $MASTER_COUNT \
        --master-size $MASTER_SIZE \
        --master-tenancy $NODE_TENANCY \
        --master-volume-size $NODE_VOLUME_SIZE \
        --master-zones $NODE_ZONES \
        --network-cidr $NETWORK_CIDR \
        --networking $CNI \
        --node-count $WORKER_COUNT \
        --node-size $WORKER_SIZE \
        --node-tenancy $NODE_TENANCY \
        --node-volume-size $NODE_VOLUME_SIZE \
        --ssh-access $NETWORK_CIDR \
        --ssh-public-key $SSH_PUB_KEY_DIR \
        --topology "private" \
        --zones $NODE_ZONES \
#        --output yaml \
#        --dry-run
else
        echo "Network security is not set in config"
fi


# CLI REFERENCE
#
# kops create cluster <clusterName>
#      --admin-access strings             Restrict API access to this CIDR.  If not set, access will not be restricted by IP. (default [0.0.0.0/0])
#      --api-loadbalancer-type string     Sets the API loadbalancer type to either 'public' or 'internal'
#      --api-ssl-certificate string       Currently only supported in AWS. Sets the ARN of the SSL Certificate to use for the API server loadbalancer.
#      --associate-public-ip              Specify --associate-public-ip=[true|false] to enable/disable association of public IP for master ASG and nodes. Default is 'true'.
#      --authorization string             Authorization mode to use: AlwaysAllow or RBAC (default "RBAC")
#      --bastion                          Pass the --bastion flag to enable a bastion instance group. Only applies to private topology.
#      --channel string                   Channel for default versions and configuration to use (default "stable")
#      --cloud string                     Cloud provider to use - gce, aws, vsphere, openstack
#      --cloud-labels string              A list of KV pairs used to tag all instance groups in AWS (e.g. "Owner=John Doe,Team=Some Team").
#      --disable-subnet-tags              Set to disable automatic subnet tagging
#      --dns string                       DNS hosted zone to use: public|private. (default "Public")
#      --dns-zone string                  DNS hosted zone to use (defaults to longest matching zone)
#      --dry-run                          If true, only print the object that would be sent, without sending it. This flag can be used to create a cluster YAML or JSON manifest.
#      --encrypt-etcd-storage             Generate key in aws kms and use it for encrypt etcd volumes
#      --etcd-storage-type string         The default storage type for etc members
#  -h, --help                             help for cluster
#      --image string                     Image to use for all instances.
#      --kubernetes-version string        Version of kubernetes to run (defaults to version in channel)
#      --master-count int32               Set the number of masters.  Defaults to one master per master-zone
#      --master-public-name string        Sets the public master public name
#      --master-security-groups strings   Add precreated additional security groups to masters.
#      --master-size string               Set instance size for masters
#      --master-tenancy string            The tenancy of the master group on AWS. Can either be default or dedicated.
#      --master-volume-size int32         Set instance volume size (in GB) for masters
#      --master-zones strings             Zones in which to run masters (must be an odd number)
#      --model string                     Models to apply (separate multiple models with commas) (default "proto,cloudup")
#      --network-cidr string              Set to override the default network CIDR
#      --networking string                Networking mode to use.  kubenet (default), classic, external, kopeio-vxlan (or kopeio), weave, flannel-vxlan (or flannel), flannel-udp, calico, canal, kube-router, romana, amazon-vpc-routed-eni, cilium, cni. (default "kubenet")
#      --node-count int32                 Set the number of nodes
#      --node-security-groups strings     Add precreated additional security groups to nodes.
#      --node-size string                 Set instance size for nodes
#      --node-tenancy string              The tenancy of the node group on AWS. Can be either default or dedicated.
#      --node-volume-size int32           Set instance volume size (in GB) for nodes
#      --os-dns-servers string            comma separated list of DNS Servers which is used in network
#      --os-ext-net string                The name of the external network to use with the openstack router
#      --os-ext-subnet string             The name of the external floating subnet to use with the openstack router
#      --os-kubelet-ignore-az             If true kubernetes may attach volumes across availability zones
#      --os-lb-floating-subnet string     The name of the external subnet to use with the kubernetes api
#      --os-octavia                       If true octavia loadbalancer api will be used
#      --out string                       Path to write any local output
#  -o, --output string                    Output format. One of json|yaml. Used with the --dry-run flag.
#      --project string                   Project to use (must be set on GCE)
#      --ssh-access strings               Restrict SSH access to this CIDR.  If not set, access will not be restricted by IP. (default [0.0.0.0/0])
#      --ssh-public-key string            SSH public key to use (defaults to ~/.ssh/id_rsa.pub on AWS)
#      --subnets strings                  Set to use shared subnets
#      --target string                    Valid targets: direct, terraform, cloudformation. Set this flag to terraform if you want kops to generate terraform (default "direct")
#  -t, --topology string                  Controls network topology for the cluster: public|private. (default "public")
#      --utility-subnets strings          Set to use shared utility subnets
#      --vpc string                       Set to use a shared VPC
#  -y, --yes                              Specify --yes to immediately create the cluster
#      --zones strings                    Zones in which to run the cluster
#
# Global Flags:
#      --alsologtostderr                  log to standard error as well as files
#      --config string                    yaml config file (default is $HOME/.kops.yaml)
#      --log_backtrace_at traceLocation   when logging hits line file:N, emit a stack trace (default :0)
#      --log_dir string                   If non-empty, write log files in this directory
#      --log_file string                  If non-empty, use this log file
#      --log_file_max_size uint           Defines the maximum size a log file can grow to. Unit is megabytes. If the value is 0, the maximum file size is unlimited. (default 1800)
#      --logtostderr                      log to standard error instead of files (default true)
#      --name string                      Name of cluster. Overrides KOPS_CLUSTER_NAME environment variable
#      --skip_headers                     If true, avoid header prefixes in the log messages
#      --skip_log_headers                 If true, avoid headers when opening log files
#      --state string                     Location of state storage (kops 'config' file). Overrides KOPS_STATE_STORE environment variable
#      --stderrthreshold severity         logs at or above this threshold go to stderr (default 2)
#  -v, --v Level                          number for the log level verbosity
#      --vmodule moduleSpec               comma-separated list of pattern=N settings for file-filtered logging

