###############################################################
# EKS Cluster
###############################################################
locals {
  admin_arns = distinct(concat(
    [for admin_user in var.aws_admin_usernames : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:user/${admin_user}"],
    [data.aws_caller_identity.current.arn]
  ))
  aws_auth_users = [for admin_user in var.aws_admin_usernames : {
    userarn  = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:user/${admin_user}"
    username = admin_user
    groups   = ["system:masters"]
  }]

  eks_admin_arns = length(local.admin_arns) == 0 ? [] : local.admin_arns

  # Used to resolve non-MFA policy. See https://docs.fugue.co/FG_R00255.html
  auth_eks_role_policy = var.eks_use_mfa ? jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          AWS = local.eks_admin_arns
        },
        Effect = "Allow"
        Sid    = ""
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      }
    ]
    }) : jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          AWS = local.eks_admin_arns
        },
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })

  aws_eks_auth_roles = concat(
    var.aws_auth_roles,
    [
      {
        rolearn  = aws_iam_role.auth_eks_role.arn
        username = aws_iam_role.auth_eks_role.name
        groups   = ["system:masters"]
      }
  ])
}

module "aws_eks" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v19.15.3"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  vpc_id                          = var.vpc_id
  subnet_ids                      = var.private_subnet_ids
  control_plane_subnet_ids        = var.control_plane_subnet_ids
  iam_role_permissions_boundary   = var.iam_role_permissions_boundary
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  self_managed_node_group_defaults = var.self_managed_node_group_defaults
  eks_managed_node_group_defaults  = var.eks_managed_node_group_defaults
  self_managed_node_groups         = var.self_managed_node_groups
  eks_managed_node_groups          = var.eks_managed_node_groups

  dataplane_wait_duration = var.dataplane_wait_duration

  cluster_addons = var.cluster_addons

  #----------------------------------------------------------------------------------------------------------#
  # Security groups used in this module created by the upstream modules terraform-aws-eks (https://github.com/terraform-aws-modules/terraform-aws-eks).
  #   Upstream module implemented Security groups based on the best practices doc https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html.
  #   So, by default the security groups are restrictive. Users needs to enable rules for specific ports required for App requirement or Add-ons
  #   See the notes below for each rule used in these examples
  #----------------------------------------------------------------------------------------------------------#
  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules


  create_aws_auth_configmap = var.create_aws_auth_configmap
  manage_aws_auth_configmap = var.manage_aws_auth_configmap

  kms_key_administrators = distinct(concat(local.admin_arns, var.kms_key_administrators))
  aws_auth_users         = distinct(concat(local.aws_auth_users, var.aws_auth_users))
  aws_auth_roles         = local.aws_eks_auth_roles

  tags = var.tags
}

resource "aws_iam_role" "auth_eks_role" {
  name                 = "${var.name}-auth-eks-role"
  description          = "EKS AuthConfig Role"
  permissions_boundary = var.iam_role_permissions_boundary
  assume_role_policy   = local.auth_eks_role_policy
  # max_session_duration = var.eks_iam_role_max_session
}
