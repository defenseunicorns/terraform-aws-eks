################################################################################
# EKS Blueprints Add-Ons
################################################################################

locals {
  node_group_arns = concat(
    [for key, value in module.aws_eks.self_managed_node_groups : lookup(value, "autoscaling_group_arn", "")],
    [for key, value in module.aws_eks.eks_managed_node_groups : lookup(value, "node_group_arn", "")]
  )
}

module "eks_blueprints_kubernetes_addons" {
  source = "git::https://github.com/aws-ia/terraform-aws-eks-blueprints-addons.git?ref=v1.5.1"

  eks_cluster_id       = module.aws_eks.cluster_name
  eks_cluster_endpoint = module.aws_eks.cluster_endpoint
  eks_oidc_provider    = module.aws_eks.oidc_provider
  eks_cluster_version  = module.aws_eks.cluster_version

  # time_sleep w/ trigger for nodes to be deployed
  create_delay_dependencies = local.node_group_arns

  # only used for aws_node_termination_handler, if this list is empty, then enable_aws_node_termination_handler should also be false.
  auto_scaling_group_names = local.node_group_arns

  # EKS EFS CSI Driver
  enable_aws_efs_csi_driver = var.enable_amazon_eks_aws_efs_csi_driver

  # K8s Add-ons

  # EKS Metrics Server
  enable_metrics_server = var.enable_metrics_server
  metrics_servier       = var.metrics_server

  # EKS AWS node termination handler
  enable_aws_node_termination_handler = var.enable_aws_node_termination_handler
  aws_node_termination_handler        = var.aws_node_termination_handler

  # EKS Cluster Autoscaler
  enable_cluster_autoscaler      = var.enable_cluster_autoscaler
  cluster_autoscaler_helm_config = var.cluster_autoscaler_helm_config

  # Calico
  enable_calico      = var.enable_calico
  calico_helm_config = var.calico_helm_config

  tags = var.tags
}

################################################################################
# Storage Classes
################################################################################

resource "kubernetes_annotations" "gp2" {
  count = var.enable_gp3_default_storage_class && var.enable_amazon_eks_aws_ebs_csi_driver ? 1 : 0

  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  force       = "true"

  metadata {
    name = "gp2"
  }

  annotations = {
    # Modify annotations to remove gp2 as default storage class still reatain the class
    "storageclass.kubernetes.io/is-default-class" = "false"
  }

  depends_on = [
    module.eks_blueprints_kubernetes_addons
  ]
}

resource "kubernetes_storage_class_v1" "gp3" {
  count = var.enable_gp3_default_storage_class && var.enable_amazon_eks_aws_ebs_csi_driver ? 1 : 0

  metadata {
    name = "gp3"

    annotations = {
      # Annotation to set gp3 as default storage class
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  allow_volume_expansion = true
  reclaim_policy         = var.storageclass_reclaim_policy
  volume_binding_mode    = "WaitForFirstConsumer"

  parameters = {
    encrypted = true
    fsType    = "ext4"
    type      = "gp3"
  }

  depends_on = [
    module.eks_blueprints_kubernetes_addons
  ]
}

################################################################################
# EBS CSI Driver Configurations
################################################################################

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  count = var.enable_amazon_eks_aws_ebs_csi_driver ? 1 : 0

  role_name_prefix = "${module.aws_eks.cluster_name}-ebs-csi-driver-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.aws_eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = var.tags
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
    for k, v in zipmap(local.availability_zone_name, var.private_subnet_ids) : k => { subnet_id = v }
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
