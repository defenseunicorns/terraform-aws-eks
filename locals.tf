locals {
  cluster_name = "${var.cluster_name}-${lower(random_id.default.hex)}"
  cluster_version = "1.30"
  admin_arns = distinct(concat(
    [for admin_user in var.aws_admin_usernames : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:user/${admin_user}"],
    [data.aws_iam_session_context.current.issuer_arn]
  ))

  ############
  # cluster_addons additional logic
  ############

  # Define default addons that should always be enabled
  default_cluster_addons = {
    "coredns"                     = {}
    "eks-pod-identity-webhook"    = {}
    "kube-proxy"                  = {}
    "vpc-cni"                     = {}
  }

  # Merge user-provided cluster_addons with default_cluster_addons
  # User-provided values in var.cluster_addons will override defaults
  merged_cluster_addons = merge(
    local.default_cluster_addons,
    var.cluster_addons
  )

  # Determine if aws-ebs-csi-driver addon should be configured
  should_config_ebs_csi_driver = (
    var.enable_amazon_eks_aws_ebs_csi_driver &&
    contains(keys(local.merged_cluster_addons), "aws-ebs-csi-driver")
  )

  # Merge in the service_account_role_arn for aws-ebs-csi-driver if needed
  ebs_csi_driver_addon_extra_config = local.should_config_ebs_csi_driver ? {
    "aws-ebs-csi-driver" = merge(
      local.merged_cluster_addons["aws-ebs-csi-driver"],
      {
        service_account_role_arn = module.ebs_csi_driver_irsa[0].iam_role_arn
      }
    )
  } : {}

  # Determine if aws-efs-csi-driver addon should be configured
  should_config_efs_csi_driver = (
    var.enable_amazon_eks_aws_efs_csi_driver &&
    contains(keys(local.merged_cluster_addons), "aws-efs-csi-driver")
  )

  # Merge in the service_account_role_arn for aws-efs-csi-driver if needed
  efs_csi_driver_addon_extra_config = local.should_config_efs_csi_driver ? {
    "aws-efs-csi-driver" = merge(
      local.merged_cluster_addons["aws-efs-csi-driver"],
      {
        service_account_role_arn = module.efs_csi_driver_irsa[0].iam_role_arn
      }
    )
  } : {}

  # Determine if ENI configs should be created for VPC CNI
  should_create_eni_configs = (
    var.create_eni_configs &&
    contains(keys(local.merged_cluster_addons), "vpc-cni") &&
    length(var.vpc_cni_custom_subnet) != 0 &&
    length(var.vpc_cni_custom_subnet) == length(var.azs)
  )

  # Define ENI Configurations if needed
  eniConfig = local.should_create_eni_configs ? {
    create = true
    region = var.aws_region
    subnets = {
      for az, subnet in zipmap(var.azs, var.vpc_cni_custom_subnet) : az => {
        id             = subnet
        securityGroups = compact([
          module.aws_eks.cluster_primary_security_group_id,
          module.aws_eks.node_security_group_id,
          module.aws_eks.cluster_security_group_id
        ])
      }
    }
  } : null

  # Merge extra configuration for VPC CNI if ENI configs are needed
  vpc_cni_addon_extra_config = local.should_create_eni_configs ? {
    "vpc-cni" = merge(
      local.merged_cluster_addons["vpc-cni"],
      {
        configuration_values = jsonencode(merge(
          try(jsondecode(local.merged_cluster_addons["vpc-cni"]["configuration_values"]), {}),
          { eniConfig = local.eniConfig }
        ))
      }
    )
  } : {}

  # Final cluster_addons map
  cluster_addons = merge(
    local.merged_cluster_addons,
    local.ebs_csi_driver_addon_extra_config,
    local.efs_csi_driver_addon_extra_config,
    local.vpc_cni_addon_extra_config
  )
}

# Self Managed Node Group Locals
locals {
  self_managed_node_group_defaults = {
    iam_role_permissions_boundary          = var.iam_role_permissions_boundary
    instance_type                          = null
    update_launch_template_default_version = true
    use_mixed_instances_policy             = true

    instance_requirements = {
      allowed_instance_types = ["m6i.4xlarge", "m5a.4xlarge"] #this should be adjusted to the appropriate instance family if reserved instances are being utilized
      memory_mib = {
        min = 64000
      }
      vcpu_count = {
        min = 16
      }
    }

    placement = {
      tenancy = "dedicated"
    }

    # bootstrap_extra_args used only when you pass custom_ami_id. Allows you to change the Container Runtime for Nodes
    # e.g., bootstrap_extra_args="--use-max-pods false --container-runtime containerd"
    bootstrap_extra_args = "--use-max-pods false"

    iam_role_additional_policies = {
      AmazonEKSVPCResourceController     = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSVPCResourceController",
      AmazonElasticFileSystemFullAccess  = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonElasticFileSystemFullAccess",
      AmazonSSMManagedInstanceCore       = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore",
      AmazonEKSWorkerNodePolicy          = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy",
      AmazonEC2ContainerRegistryReadOnly = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
      AmazonEKS_CNI_Policy               = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"
    }

    # enable discovery of autoscaling groups by cluster-autoscaler
    autoscaling_group_tags = merge(
      {
        "k8s.io/cluster-autoscaler/enabled" : true,
        "k8s.io/cluster-autoscaler/${local.cluster_name}" : "owned"
    })

    metadata_options = {
      #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#metadata-options
      http_endpoint               = "enabled"
      http_put_response_hop_limit = 2
      http_tokens                 = "optional" # set to "enabled" to enforce IMDSv2, default for upstream terraform-aws-eks module
    }

    tags = {
      subnet_type                            = "private",
      cluster                                = local.cluster_name
      "aws-node-termination-handler/managed" = true # only need this if NTH is enabled. This is due to aws blueprints using this resource and causing the tags to flap on every apply https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/257677adeed1be54326637cf919cf24df6ad7c06/main.tf#L1554-L1564
    }
  }

  self_managed_node_groups = {
    uds_core_ng = {
      ami_type      = "BOTTLEROCKET_x86_64"
      ami_id        = data.aws_ami.eks_default_bottlerocket.id
      instance_type = null # conflicts with instance_requirements settings
      min_size      = 3
      max_size      = 5
      desired_size  = 3
      key_name      = module.self_managed_node_group_keypair.key_pair_name

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = 100
            volume_type = "gp3"
          }
        }
        xvdb = {
          device_name = "/dev/xvdb"
          ebs = {
            volume_size = 100
            volume_type = "gp3"
            #need to add and create EBS key
          }
        }
      }

      bootstrap_extra_args = <<-EOT
        # The admin host container provides SSH access and runs with "superpowers".
        # It is disabled by default, enabled here for easy SSH access into bottlerocket nodes with the keypair created by the module.
        [settings.host-containers.admin]
        enabled = true

        # The control host container provides out-of-band access via SSM.
        # It is enabled by default, and can be disabled if you do not expect to use SSM.
        # This could leave you with no way to access the API and change settings on an existing node!
        [settings.host-containers.control]
        enabled = true

        # extra args added
        [settings.kernel]
        lockdown = "integrity"

        [settings.kubernetes.node-labels]
        # label1 = "sso"
        # label2 = "uds-core"

        [settings.kubernetes.node-taints]
        # dedicated = "experimental:PreferNoSchedule"
        # special = "true:NoSchedule"
      EOT
    }
  }

  default_cluster_addons = {
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
      most_recent          = true
      configuration_values = <<-JSON
        "defaultStorageClass": {
          "enabled": true
        }
      JSON
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
}

# Common Environments Access Entries
locals {

  iam_role_policy_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"

  admin_user_access_entries = {
    for user in var.aws_admin_usernames :
    user => {
      principal_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:user/${user}"
      type          = "STANDARD"
      policy_associations = {
        admin = {
          policy_arn = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

    bastion = {
      principal_arn = var.bastion_role_arn
      type          = "STANDARD"
      policy_associations = {
        admin = {
          policy_arn = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }

  additional_access_entries = {
    for index in var.additional_access_entries :
    index => {
      principal_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${index}"
      type          = "STANDARD"
      policy_associations = {
        admin = {
          policy_arn = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  access_entries = merge(
    local.admin_user_access_entries,
    local.additional_access_entries
  )
} # END: Common Environments Access Entries
