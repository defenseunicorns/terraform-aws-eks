region                         = "us-east-2"
region2                        = "us-east-1"
enable_eks_managed_nodegroups  = false
enable_self_managed_nodegroups = true
bastion_tenancy                = "dedicated"
eks_worker_tenancy             = "dedicated"
cluster_endpoint_public_access = false
eks_use_mfa                    = false
create_aws_auth_configmap = true #secure example assumes enable_eks_managed_nodegroups = false, need to create the configmap ourselves