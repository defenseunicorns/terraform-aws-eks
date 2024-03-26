enable_eks_managed_nodegroups  = false
enable_self_managed_nodegroups = true
bastion_tenancy                = "dedicated"
eks_worker_tenancy             = "dedicated"
cluster_endpoint_public_access = true

# due to private endpoint in the secure example, users will need to use sshuttle to connect to the cluster
create_kubernetes_resources = true
