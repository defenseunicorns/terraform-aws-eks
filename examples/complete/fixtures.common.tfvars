###########################################################
################## Global Settings ########################

# Setting region per test case to avoid AWS service quota limits
#region  = "us-east-2" # target AWS region
#region2 = "us-east-1" # RDS backup target AWS region
name_prefix = "ci"

###########################################################
#################### VPC Config ###########################

vpc_cidr              = "10.200.0.0/16"
secondary_cidr_blocks = ["100.64.0.0/16"] #https://aws.amazon.com/blogs/containers/optimize-ip-addresses-usage-by-pods-in-your-amazon-eks-cluster/

# new_bits is added to the cidr of vpc_cidr to chunk the subnets up
# public-a - 10.200.0.0/22 - 1,022 hosts
# public-b - 10.200.4.0/22 - 1,022 hosts
# public-c - 10.200.8.0/22 - 1,022 hosts
# private-a - 10.200.12.0/22 - 1,022 hosts
# private-b - 10.200.16.0/22 - 1,022 hosts
# private-c - 10.200.20.0/22 - 1,022 hosts
# database-a - 10.200.24.0/27 - 30 hosts
# database-b - 10.200.24.32/27 - 30 hosts
# database-c - 10.200.24.64/27 - 30 hosts
vpc_subnets = [
  {
    name     = "public-a"
    new_bits = 6
  },
  {
    name     = "public-b"
    new_bits = 6
  },
  {
    name     = "public-c"
    new_bits = 6
  },
  {
    name     = "private-a"
    new_bits = 6
  },
  {
    name     = "private-b"
    new_bits = 6
  },
  {
    name     = "private-c"
    new_bits = 6
  },
  {
    name     = "database-a"
    new_bits = 11
  },
  {
    name     = "database-b"
    new_bits = 11
  },
  {
    name     = "database-c"
    new_bits = 11
  },
]

###########################################################
################## Bastion Config #########################

bastion_ssh_user     = "ec2-user" # local user in bastion used to ssh
bastion_ssh_password = "my-password"
zarf_version         = "v0.29.1"

###########################################################
#################### EKS Config ###########################

cluster_version = "1.29"

# #################### EKS Addon #########################
# add other "eks native" marketplace addons and configs to this list
cluster_addons = {
  vpc-cni = {
    most_recent          = true
    before_compute       = true
    configuration_values = <<-JSON
      {
        "env": {
          "AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG": "true",
          "ENABLE_PREFIX_DELEGATION": "true",
          "ENI_CONFIG_LABEL_DEF": "topology.kubernetes.io/zone",
          "WARM_PREFIX_TARGET": "1",
          "ANNOTATE_POD_IP": "true",
          "POD_SECURITY_GROUP_ENFORCING_MODE": "standard"
        },
        "enableNetworkPolicy": "true"
      }
    JSON
  }
  coredns = {
    most_recent = true
    timeouts = {
      create = "10m"
      delete = "10m"
    }
  }
  kube-proxy = {
    most_recent = true
  }
  aws-ebs-csi-driver = {
    most_recent = true
    timeouts = {
      create = "10m"
      delete = "10m"
    }
  }
  # consider using '"useFIPS": "true"' under configuration_values for aws_efs_csi_driver
  aws-efs-csi-driver = {
    most_recent = true
    timeouts = {
      create = "10m"
      delete = "10m"
    }
  }
}

enable_amazon_eks_aws_efs_csi_driver = true
enable_amazon_eks_aws_ebs_csi_driver = true
enable_gp3_default_storage_class     = true

#################### Blueprints addons ###################
#wait false for all addons, as it times out on teardown in the test pipeline

enable_aws_node_termination_handler = true
aws_node_termination_handler = {
  wait          = false
  chart_version = "v0.21.0"
}

enable_cluster_autoscaler = true
cluster_autoscaler = {
  wait          = false
  chart_version = "v9.29.1"
}

enable_metrics_server = true
metrics_server = {
  wait          = false
  chart_version = "v3.10.0"
}

enable_aws_load_balancer_controller = true
aws_load_balancer_controller = {
  wait          = false
  chart_version = "v1.6.0"
}

enable_secrets_store_csi_driver = true
secrets_store_csi_driver = {
  wait          = false
  chart_version = "v1.3.4"
}
