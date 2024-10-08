################################################################################
# EKS Blueprints Add-Ons
################################################################################

locals {
  node_group_arns = [for key, value in module.aws_eks.self_managed_node_groups : lookup(value, "autoscaling_group_arn", "")]

  # set default resource arns for external secrets  IAM policy if not defined relative to the current AWS partition, only used if external secrets is enabled
  external_secrets_ssm_parameter_arns   = length(var.external_secrets_ssm_parameter_arns) > 0 ? var.external_secrets_ssm_parameter_arns : ["arn:${data.aws_partition.current.partition}:ssm:*:*:parameter/*"]
  external_secrets_secrets_manager_arns = length(var.external_secrets_secrets_manager_arns) > 0 ? var.external_secrets_secrets_manager_arns : ["arn:${data.aws_partition.current.partition}:secretsmanager:*:*:secret:*"]
  external_secrets_kms_key_arns         = length(var.external_secrets_kms_key_arns) > 0 ? var.external_secrets_kms_key_arns : ["arn:${data.aws_partition.current.partition}:kms:*:*:key/*"]

  # set default resource arns for cert manager IAM policy if not defined relative to the current AWS partition, only used if cert manager is enabled
  cert_manager_route53_hosted_zone_arns = length(var.cert_manager_route53_hosted_zone_arns) > 0 ? var.cert_manager_route53_hosted_zone_arns : ["arn:${data.aws_partition.current.partition}:route53:::hostedzone/*"]
}

module "eks_blueprints_kubernetes_addons" {
  source = "git::https://github.com/aws-ia/terraform-aws-eks-blueprints-addons.git?ref=v1.16.3"

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
  create_kubernetes_resources = false

  # EKS Metrics Server
  enable_metrics_server = var.enable_metrics_server

  # EKS AWS node termination handler
  enable_aws_node_termination_handler = var.enable_aws_node_termination_handler

  # EKS Cluster Autoscaler
  enable_cluster_autoscaler = var.enable_cluster_autoscaler

  # EKS AWS Load Balancer Controller
  enable_aws_load_balancer_controller = true

  # K8s Secrets Store CSI Driver
  enable_secrets_store_csi_driver = var.enable_secrets_store_csi_driver

  # External Secrets
  enable_external_secrets               = var.enable_external_secrets
  external_secrets_ssm_parameter_arns   = local.external_secrets_ssm_parameter_arns
  external_secrets_secrets_manager_arns = local.external_secrets_secrets_manager_arns
  external_secrets_kms_key_arns         = local.external_secrets_kms_key_arns

  # Karpenter
  enable_karpenter = true

  # Bottlerocket update operator
  enable_bottlerocket_update_operator = true

  # AWS Cloudwatch Metrics
  enable_aws_cloudwatch_metrics = var.enable_aws_cloudwatch_metrics

  # AWS FSX CSI Driver
  enable_aws_fsx_csi_driver = var.enable_aws_fsx_csi_driver

  # AWS Private CA Issuer
  enable_aws_privateca_issuer = var.enable_aws_privateca_issuer

  # Cert Manager
  enable_cert_manager                   = var.enable_cert_manager
  cert_manager_route53_hosted_zone_arns = local.cert_manager_route53_hosted_zone_arns

  # External DNS
  enable_external_dns = var.enable_external_dns

  tags = var.tags

  depends_on = [
    module.aws_eks.access_entries,
    module.aws_eks.access_policy_associations
  ]
}


################################################################################
# EFS CSI Driver Configurations
################################################################################

resource "random_id" "efs_name" {
  byte_length = 2
  prefix      = "EFS-"
}

module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "~> 1.0"

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
      cidr_blocks = var.efs_vpc_cidr_blocks
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

  ssm_parameter_kms_key_arn = length(var.ssm_parameter_kms_key_arn) > 0 ? var.ssm_parameter_kms_key_arn : "alias/aws/ssm"
}

resource "aws_ssm_parameter" "helm_input_values" {
  for_each = var.create_ssm_parameters ? local.structured_gitops_metadata : {}

  name   = "/${local.cluster_name}/${each.key}_helm_input_values"
  value  = jsonencode(each.value)
  type   = "SecureString"
  key_id = local.ssm_parameter_kms_key_arn
  tier   = "Standard"

  tags = var.tags
}

# Create ssm parameter for EFS storage class for external EFS CSI driver storage class configuration because marketplace EFS CSI driver does not support storageclass provisioning
# https://github.com/aws/containers-roadmap/issues/2198
resource "aws_ssm_parameter" "file_system_id_for_efs_storage_class" {
  count  = var.create_ssm_parameters ? 1 : 0
  name   = "/${local.cluster_name}/StorageClass/efs/fileSystemId"
  value  = module.efs.id
  type   = "SecureString"
  key_id = local.ssm_parameter_kms_key_arn
  tier   = "Standard"

  tags = var.tags
}
