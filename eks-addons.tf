################################################################################
# EKS Blueprints Add-Ons
################################################################################

locals {
  node_group_arns = [for key, value in module.aws_eks.self_managed_node_groups : lookup(value, "autoscaling_group_arn", "")]
}

module "eks_blueprints_kubernetes_addons" {
  source = "git::https://github.com/aws-ia/terraform-aws-eks-blueprints-addons.git?ref=v1.13.0"

  cluster_name      = module.aws_eks.cluster_name
  cluster_endpoint  = module.aws_eks.cluster_endpoint
  oidc_provider_arn = module.aws_eks.oidc_provider_arn
  cluster_version   = module.aws_eks.cluster_version

  # time_sleep w/ trigger for nodes to be deployed
  create_delay_dependencies = local.node_group_arns

  # only used for aws_node_termination_handler, if this list is empty, then enable_aws_node_termination_handler should also be false.
  # you don't need to tag eks managed node group ASGs for NTH - https://github.com/aws/aws-node-termination-handler/blob/main/README.md?plain=1#L41
  aws_node_termination_handler_asg_arns = local.node_group_arns

  #this controls whether or not the cluster resources are created for the blueprints eks addons module
  create_kubernetes_resources = var.create_kubernetes_resources

  # EKS EFS CSI Driver
  enable_aws_efs_csi_driver = var.enable_amazon_eks_aws_efs_csi_driver
  aws_efs_csi_driver        = var.aws_efs_csi_driver

  # EKS Metrics Server
  enable_metrics_server = var.enable_metrics_server
  metrics_server        = var.metrics_server

  # EKS AWS node termination handler
  enable_aws_node_termination_handler = var.enable_aws_node_termination_handler
  aws_node_termination_handler        = var.aws_node_termination_handler

  # EKS Cluster Autoscaler
  enable_cluster_autoscaler = var.enable_cluster_autoscaler
  cluster_autoscaler        = var.cluster_autoscaler

  # EKS AWS Load Balancer Controller
  enable_aws_load_balancer_controller = var.enable_aws_load_balancer_controller
  aws_load_balancer_controller        = var.aws_load_balancer_controller

  # K8s Secrets Store CSI Driver
  enable_secrets_store_csi_driver = var.enable_secrets_store_csi_driver
  secrets_store_csi_driver        = var.secrets_store_csi_driver

  # Arbitrary helm charts can be fed into a helm_release var in blueprints. Note that the standard "create" var doesn't work with these
  # see https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/main/docs/helm-release.md

  tags = var.tags

  depends_on = [
    module.aws_eks.access_entries
  ]
}

################################################################################
# EFS CSI Driver Configurations
################################################################################

resource "random_id" "efs_name" {
  byte_length = 2
  prefix      = "EFS-"
}

resource "kubernetes_storage_class_v1" "efs" {
  count = var.enable_amazon_eks_aws_efs_csi_driver ? 1 : 0
  metadata {
    name = lower(random_id.efs_name.hex)
  }

  storage_provisioner = "efs.csi.aws.com"
  reclaim_policy      = var.reclaim_policy
  parameters = {
    provisioningMode = "efs-ap" # Dynamic provisioning
    fileSystemId     = module.efs[0].id
    directoryPerms   = "700"
  }
  mount_options = [
    "iam"
  ]

  depends_on = [
    module.eks_blueprints_kubernetes_addons
  ]
}

module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "~> 1.0"

  count = var.enable_amazon_eks_aws_efs_csi_driver ? 1 : 0

  name = lower(random_id.efs_name.hex)
  # Mount targets / security group
  mount_targets = {
    for k, v in zipmap(var.azs, var.private_subnet_ids) : k => { subnet_id = v }
  }

  security_group_description = "${local.cluster_name} EFS security group"
  security_group_vpc_id      = var.vpc_id
  security_group_rules = {
    vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = var.cidr_blocks
    }
  }

  tags = var.tags
}

################################################################################
# SSM parameter creation
################################################################################

locals {
  # creates a map of maps for each enabled addon, with the addon prefix as the key and then is used to create a json encoded string for the ssm parameter values
  structured_gitops_metadata = {
    for prefix in var.blueprints_addons_prefixes :
    prefix => {
      for k, v in module.eks_blueprints_kubernetes_addons.gitops_metadata :
      replace(k, "${prefix}_", "") => v if startswith(k, prefix)
      } if length({
        for k, v in module.eks_blueprints_kubernetes_addons.gitops_metadata :
        replace(k, "${prefix}_", "") => v if startswith(k, prefix)
    }) > 0
  }

  ssm_parameter_key_arn = length(var.ssm_parameter_key_arn) > 0 ? var.ssm_parameter_key_arn : "alias/aws/ssm"
}

resource "aws_ssm_parameter" "helm_input_values" {
  for_each = var.create_ssm_parameters ? local.structured_gitops_metadata : {}

  name   = "/${local.cluster_name}/${each.key}_helm_input_values"
  value  = jsonencode(each.value)
  type   = "SecureString"
  key_id = local.ssm_parameter_key_arn
  tier   = "Standard"

  tags = var.tags
}
