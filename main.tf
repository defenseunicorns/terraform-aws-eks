data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  # This data source provides information on the IAM source role of an STS assumed role
  # For non-role ARNs, this data source simply passes the ARN through issuer ARN
  # Ref https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2327#issuecomment-1355581682
  # Ref https://github.com/hashicorp/terraform-provider-aws/issues/28381
  arn = data.aws_caller_identity.current.arn
}

###############################################################
# EKS Cluster
###############################################################
locals {
  cluster_name = coalesce(var.cluster_name, var.name)
  admin_arns = distinct(concat(
    [for admin_user in var.aws_admin_usernames : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:user/${admin_user}"],
    [data.aws_iam_session_context.current.issuer_arn]
  ))

  ############
  # cluster_addons additional logic
  ############

  # ebs_csi_driver_addon_extra_config is used to merge in the service_account_role_arn to the existing aws-ebs-csi-driver config in cluster_addons
  should_config_ebs_csi_driver = (
    var.enable_amazon_eks_aws_ebs_csi_driver &&
    var.cluster_addons["aws-ebs-csi-driver"] != null
  )

  # Merge in the service_account_role_arn to the existing aws-ebs-csi-driver config
  ebs_csi_driver_addon_extra_config = local.should_config_ebs_csi_driver ? {
    "aws-ebs-csi-driver" = merge(
      var.cluster_addons["aws-ebs-csi-driver"],
      {
        service_account_role_arn = module.ebs_csi_driver_irsa[0].iam_role_arn
      }
    )
  } : {}

  should_config_efs_csi_driver = (
    var.enable_amazon_eks_aws_efs_csi_driver &&
    var.cluster_addons["aws-efs-csi-driver"] != null
  )

  # Merge in the service_account_role_arn to the existing aws-ebs-csi-driver config
  efs_csi_driver_addon_extra_config = local.should_config_efs_csi_driver ? {
    "aws-efs-csi-driver" = merge(
      var.cluster_addons["aws-efs-csi-driver"],
      {
        service_account_role_arn = module.efs_csi_driver_irsa[0].iam_role_arn
      }
    )
  } : {}

  # Check conditions for whether ENI configs should be created for VPC CNI.
  # Conditions include: VPC CNI configured in var.cluster_addons, custom subnet should be provided, and the number of custom subnets should match the number of availability zones.
  should_create_eni_configs = (
    var.create_eni_configs &&
    var.cluster_addons["vpc-cni"] != null &&
    length(var.vpc_cni_custom_subnet) != 0 &&
    length(var.vpc_cni_custom_subnet) == length(var.azs)
  )

  # Define ENI Configurations if should_create_eni_configs evaluates to true.
  eniConfig = local.should_create_eni_configs ? {
    create = true,
    region = var.aws_region,
    subnets = { for az, subnet in zipmap(var.azs, var.vpc_cni_custom_subnet) : az => {
      id = subnet,
      securityGroups = compact([
        module.aws_eks.cluster_primary_security_group_id,
        module.aws_eks.node_security_group_id,
        module.aws_eks.cluster_security_group_id
      ])
    } }
  } : null

  # Merge extra configuration for VPC CNI if should_create_eni_configs evaluates to true.
  # This merges at a deeper level to preserve existing keys like 'most_recent' and 'before_compute'.
  vpc_cni_addon_extra_config = local.should_create_eni_configs ? {
    "vpc-cni" = merge(
      var.cluster_addons["vpc-cni"],
      {
        configuration_values = jsonencode(merge(
          jsondecode(var.cluster_addons["vpc-cni"].configuration_values),
          { eniConfig = local.eniConfig }
        ))
      }
    )
  } : {}

  cluster_addons = merge(
    var.cluster_addons,
    local.ebs_csi_driver_addon_extra_config,
    local.efs_csi_driver_addon_extra_config,
    local.vpc_cni_addon_extra_config
  )
}

module "aws_eks" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v20.31.6"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  vpc_id                           = var.vpc_id
  subnet_ids                       = var.private_subnet_ids
  control_plane_subnet_ids         = var.control_plane_subnet_ids
  cluster_ip_family                = var.cluster_ip_family
  cluster_service_ipv4_cidr        = var.cluster_service_ipv4_cidr
  iam_role_permissions_boundary    = var.iam_role_permissions_boundary
  attach_cluster_encryption_policy = var.attach_cluster_encryption_policy

  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access


  self_managed_node_group_defaults = var.self_managed_node_group_defaults
  self_managed_node_groups         = var.self_managed_node_groups
  eks_managed_node_groups          = var.eks_managed_node_groups
  eks_managed_node_group_defaults  = var.eks_managed_node_group_defaults

  dataplane_wait_duration = var.dataplane_wait_duration
  cluster_timeouts        = var.cluster_timeouts

  cluster_addons = local.cluster_addons

  access_entries                           = var.access_entries
  authentication_mode                      = var.authentication_mode
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  #----------------------------------------------------------------------------------------------------------#
  #   Security groups used in this module created by the upstream modules terraform-aws-eks (https://github.com/terraform-aws-modules/terraform-aws-eks).
  #   Upstream module implemented Security groups based on the best practices doc https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html.
  #   By default the security groups are restrictive. Users needs to enable rules for specific ports required for App requirement or Add-ons
  #----------------------------------------------------------------------------------------------------------#
  node_security_group_additional_rules    = var.node_security_group_additional_rules
  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules
  cluster_additional_security_group_ids   = var.cluster_additional_security_group_ids
  create_cluster_security_group           = var.create_cluster_security_group
  cluster_security_group_id               = var.cluster_security_group_id
  cluster_security_group_name             = var.cluster_security_group_name
  cluster_security_group_use_name_prefix  = var.cluster_security_group_use_name_prefix
  cluster_security_group_description      = var.cluster_security_group_description
  cluster_security_group_tags             = var.cluster_security_group_tags

  create_kms_key                    = var.create_kms_key
  kms_key_description               = var.kms_key_description
  kms_key_deletion_window_in_days   = var.kms_key_deletion_window_in_days
  enable_kms_key_rotation           = var.enable_kms_key_rotation
  kms_key_enable_default_policy     = var.kms_key_enable_default_policy
  kms_key_owners                    = var.kms_key_owners
  kms_key_administrators            = distinct(concat(local.admin_arns, var.kms_key_administrators))
  kms_key_users                     = var.kms_key_users
  kms_key_service_users             = var.kms_key_service_users
  kms_key_source_policy_documents   = var.kms_key_source_policy_documents
  kms_key_override_policy_documents = var.kms_key_override_policy_documents
  kms_key_aliases                   = var.kms_key_aliases

  cluster_enabled_log_types              = var.cluster_enabled_log_types
  create_cloudwatch_log_group            = var.create_cloudwatch_log_group
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_kms_key_id        = var.cloudwatch_log_group_kms_key_id
  cloudwatch_log_group_class             = var.cloudwatch_log_group_class

  cluster_tags                               = var.cluster_tags
  create_cluster_primary_security_group_tags = var.create_cluster_primary_security_group_tags
  cloudwatch_log_group_tags                  = var.cloudwatch_log_group_tags
  tags                                       = var.tags

}

################################################################################
# Marketplace Addon Dependencies
################################################################################

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  count = var.enable_amazon_eks_aws_ebs_csi_driver ? 1 : 0

  role_name_prefix              = "${module.aws_eks.cluster_name}-ebs-csi-driver-"
  role_permissions_boundary_arn = var.iam_role_permissions_boundary

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.aws_eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = var.tags
}

module "efs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  count = var.enable_amazon_eks_aws_efs_csi_driver ? 1 : 0

  role_name_prefix              = "${module.aws_eks.cluster_name}-efs-csi-driver-"
  role_permissions_boundary_arn = var.iam_role_permissions_boundary

  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.aws_eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }

  tags = var.tags
}
