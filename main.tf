

###############################################################
# EKS Cluster
###############################################################

module "aws_eks" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v20.24.0"

  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  vpc_id                           = var.vpc_id
  subnet_ids                       = var.private_subnet_ids
  control_plane_subnet_ids         = var.control_plane_subnet_ids
  cluster_ip_family                = "ipv4"
  cluster_service_ipv4_cidr        = "172.20.0.0/16"
  iam_role_permissions_boundary    = var.iam_role_permissions_boundary
  attach_cluster_encryption_policy = true

  cluster_endpoint_public_access       = false
  cluster_endpoint_private_access      = true

  self_managed_node_group_defaults = local.self_managed_node_group_defaults
  self_managed_node_groups         = local.self_managed_node_groups

  dataplane_wait_duration = "30s"

  cluster_addons = local.cluster_addons

  access_entries                           = local.access_entries
  authentication_mode                      = "API"
  enable_cluster_creator_admin_permissions = true

  #----------------------------------------------------------------------------------------------------------#
  #   Security groups used in this module created by the upstream modules terraform-aws-eks (https://github.com/terraform-aws-modules/terraform-aws-eks).
  #   Upstream module implemented Security groups based on the best practices doc https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html.
  #   By default the security groups are restrictive. Users needs to enable rules for specific ports required for App requirement or Add-ons
  #----------------------------------------------------------------------------------------------------------#
  node_security_group_additional_rules    = local.node_security_group_additional_rules
  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules
  cluster_additional_security_group_ids   = var.cluster_additional_security_group_ids
  create_cluster_security_group           = true

  create_kms_key                    = true
  kms_key_description               = "aws-eks-kms-key"
  kms_key_deletion_window_in_days   = "30"
  enable_kms_key_rotation           = true
  kms_key_enable_default_policy     = true
  kms_key_owners                    = var.kms_key_owners
  kms_key_administrators            = distinct(concat(local.admin_arns, var.kms_key_administrators))
  kms_key_aliases                   = local.cluster_name

  cluster_enabled_log_types              = ["audit", "api", "authenticator"]
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 90
  cloudwatch_log_group_kms_key_id        = var.cloudwatch_log_group_kms_key_id
  cloudwatch_log_group_class             = null

  cluster_tags                               = var.cluster_tags
  create_cluster_primary_security_group_tags = true
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

######################################################
# EKS Self Managed Node Group Dependencies
######################################################
module "self_managed_node_group_keypair" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-key-pair?ref=v2.0.3"

  key_name_prefix    = "${local.cluster_name}-self-managed-ng-"
  create_private_key = true

  tags = var.tags
}

module "self_managed_node_group_secret_key_secrets_manager_secret" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-secrets-manager.git?ref=v1.1.2"

  name                    = module.self_managed_node_group_keypair.key_pair_name
  description             = "Secret key for self managed node group keypair"
  recovery_window_in_days = 0 # 0 - no recovery window, delete immediately when deleted

  block_public_policy = true

  ignore_secret_changes = true
  secret_string         = module.self_managed_node_group_keypair.private_key_openssh

  tags = var.tags
}

######################################################
# vpc-cni irsa role
######################################################
module "vpc_cni_ipv4_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"

  role_name_prefix      = "${local.cluster_name}-vpc-cni-"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.aws_eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  # extra policy to attach to the role
  role_policy_arns = {
    vpc_cni_logging = aws_iam_policy.vpc_cni_logging.arn
  }

  tags = var.tags
}

resource "aws_iam_policy" "vpc_cni_logging" {
  # checkov:skip=CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  # checkov:skip=CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints"
  name        = "${var.name}-vpc-cni-logging-${lower(random_id.default.hex)}"
  description = "Additional test policy"

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "CloudWatchLogging"
          Effect = "Allow"
          Action = [
            "logs:DescribeLogGroups",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "*"
        }
      ]
    }
  )

  tags = var.tags
}
