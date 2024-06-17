enable_eks_managed_nodegroups  = false
enable_self_managed_nodegroups = true
eks_worker_tenancy             = "dedicated"
cluster_endpoint_public_access = true

# due to private endpoint in the secure example, users will need to use sshuttle or AWS SSM port forwarding to connect to the kubernetes cluster endpoint
create_kubernetes_resources = false
