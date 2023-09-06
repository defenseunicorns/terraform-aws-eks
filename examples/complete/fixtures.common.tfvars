###########################################################
################## Global Settings ########################

# Setting region per test case to avoid AWS service quota limits
#region  = "us-east-2" # target AWS region
#region2 = "us-east-1" # RDS backup target AWS region
name_prefix               = "ci"
manage_aws_auth_configmap = true

###########################################################
#################### VPC Config ###########################

vpc_cidr              = "10.200.0.0/16"
secondary_cidr_blocks = ["100.64.0.0/16"] #https://aws.amazon.com/blogs/containers/optimize-ip-addresses-usage-by-pods-in-your-amazon-eks-cluster/

###########################################################
################## Bastion Config #########################

bastion_ssh_user     = "ec2-user" # local user in bastion used to ssh
bastion_ssh_password = "my-password"
zarf_version         = "v0.29.1"

###########################################################
#################### EKS Config ###########################

cluster_version = "1.26"

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
    preserve    = true
    most_recent = true

    timeouts = {
      create = "2m"
      delete = "10m"
    }
  }
  kube-proxy = {
    most_recent = true
  }
  aws-ebs-csi-driver = {
    preserve    = true
    most_recent = true
    timeouts = {
      create = "4m"
      delete = "10m"
    }
  }
}

enable_amazon_eks_aws_ebs_csi_driver = true
enable_gp3_default_storage_class     = true

#################### Blueprints addons ###################
#wait false for all addons, as it times out on teardown in the test pipeline

enable_amazon_eks_aws_efs_csi_driver = true
aws_efs_csi_driver = {
  wait          = false
  chart_version = "2.4.8"
}

enable_aws_node_termination_handler = true
aws_node_termination_handler = {
  wait          = false
  chart_version = "v0.21.0"
}

enable_cluster_autoscaler = true
cluster_autoscaler = {
  wait          = false
  chart_version = "v9.29.1"
  # set = [
  #   {
  #     name  = "extraArgs.expander"
  #     value = "priority"
  #   },
  #   {
  #     name  = "image.tag"
  #     value = "v1.27.2"
  #   }
  # ]
}

enable_metrics_server = true
metrics_server = {
  wait          = false
  chart_version = "v3.10.0"
}
