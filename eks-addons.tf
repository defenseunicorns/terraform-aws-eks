#---------------------------------------------------------------
# EKS Add-Ons
#---------------------------------------------------------------

locals {
  self_managed_node_group_names = [for key, value in module.aws_eks.self_managed_node_groups : lookup(value, "autoscaling_group_name", "")]
}

module "eks_blueprints_kubernetes_addons" {
  source = "git::https://github.com/aws-ia/terraform-aws-eks-blueprints.git//modules/kubernetes-addons?ref=v4.32.1"

  eks_cluster_id                = module.aws_eks.cluster_name
  eks_cluster_endpoint          = module.aws_eks.cluster_endpoint
  eks_oidc_provider             = module.aws_eks.oidc_provider
  eks_cluster_version           = module.aws_eks.cluster_version
  irsa_iam_permissions_boundary = var.iam_role_permissions_boundary

  # only used for aws_node_termination_handler, if this list is empty, then enable_aws_node_termination_handler should also be false.
  auto_scaling_group_names = local.self_managed_node_group_names

  # blueprints addons

  # EKS EBS CSI Driver
  enable_amazon_eks_aws_ebs_csi_driver = var.enable_amazon_eks_aws_ebs_csi_driver
  amazon_eks_aws_ebs_csi_driver_config = var.amazon_eks_aws_ebs_csi_driver_config

  # EKS EFS CSI Driver
  enable_aws_efs_csi_driver = var.enable_efs

  # K8s Add-ons

  # EKS Metrics Server
  enable_metrics_server      = var.enable_metrics_server
  metrics_server_helm_config = var.metrics_server_helm_config

  # EKS AWS node termination handler
  enable_aws_node_termination_handler      = var.enable_aws_node_termination_handler
  aws_node_termination_handler_helm_config = var.aws_node_termination_handler_helm_config

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
  count = var.enable_gp3_default_storage_class ? 1 : 0

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
  count = var.enable_gp3_default_storage_class ? 1 : 0

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
