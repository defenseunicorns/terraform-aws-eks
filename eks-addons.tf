################################################################################
# EKS Blueprints Add-Ons
################################################################################

data "aws_autoscaling_group" "managed_ng" {
  for_each = { for node_group_name in module.aws_eks.eks_managed_node_groups_autoscaling_group_names : node_group_name => node_group_name }
  name     = each.value
}

locals {
  node_group_arns = concat(
    [for key, value in module.aws_eks.self_managed_node_groups : lookup(value, "autoscaling_group_arn", "")],
    [for key, value in data.aws_autoscaling_group.managed_ng : value.arn]
  )
}

module "eks_blueprints_kubernetes_addons" {
  source = "git::https://github.com/aws-ia/terraform-aws-eks-blueprints-addons.git?ref=v1.5.1"

  cluster_name      = module.aws_eks.cluster_name
  cluster_endpoint  = module.aws_eks.cluster_endpoint
  oidc_provider_arn = module.aws_eks.oidc_provider
  cluster_version   = module.aws_eks.cluster_version

  # time_sleep w/ trigger for nodes to be deployed
  create_delay_dependencies = local.node_group_arns

  # only used for aws_node_termination_handler, if this list is empty, then enable_aws_node_termination_handler should also be false.
  aws_node_termination_handler_asg_arns = local.node_group_arns

  # EKS EFS CSI Driver
  enable_aws_efs_csi_driver = var.enable_amazon_eks_aws_efs_csi_driver

  # K8s Add-ons

  # EKS Metrics Server
  enable_metrics_server = var.enable_metrics_server
  metrics_server        = var.metrics_server

  # EKS AWS node termination handler
  enable_aws_node_termination_handler = var.enable_aws_node_termination_handler
  aws_node_termination_handler        = var.aws_node_termination_handler

  # EKS Cluster Autoscaler
  enable_cluster_autoscaler = var.enable_cluster_autoscaler
  cluster_autoscaler        = var.cluster_autoscaler

  # Arbitrary helm charts can be fed into a helm_release var in blueprints. Note that the standard "create" var doesn't work with these
  # see https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/main/docs/helm-release.md

  tags = var.tags
}

################################################################################
# Custom Addons
################################################################################

# Calico
module "calico" {
  source = "git::https://github.com/aws-ia/terraform-aws-eks-blueprints-addon.git?ref=v1.1.0"

  create = var.enable_calico

  # https://github.com/aws/eks-charts/blob/master/stable/aws-load-balancer-controller/Chart.yaml
  name             = try(var.calico.name, "calico")
  description      = try(var.calico.description, "calico helm Chart deployment configuration")
  namespace        = try(var.calico.namespace, "tigera-operator")
  create_namespace = try(var.calico.create_namespace, true)
  chart            = try(var.calico.chart, "tigera-operator")
  chart_version    = try(var.calico.chart_version, "v3.26.1")
  repository       = try(var.calico.repository, "https://docs.projectcalico.org/charts")
  values = try(var.calico.values, [
    <<-EOT
      installation:
        kubernetesProvider: "EKS"
    EOT
  ])

  timeout                    = try(var.calico.timeout, null)
  repository_key_file        = try(var.calico.repository_key_file, null)
  repository_cert_file       = try(var.calico.repository_cert_file, null)
  repository_ca_file         = try(var.calico.repository_ca_file, null)
  repository_username        = try(var.calico.repository_username, null)
  repository_password        = try(var.calico.repository_password, null)
  devel                      = try(var.calico.devel, null)
  verify                     = try(var.calico.verify, null)
  keyring                    = try(var.calico.keyring, null)
  disable_webhooks           = try(var.calico.disable_webhooks, null)
  reuse_values               = try(var.calico.reuse_values, null)
  reset_values               = try(var.calico.reset_values, null)
  force_update               = try(var.calico.force_update, null)
  recreate_pods              = try(var.calico.recreate_pods, null)
  cleanup_on_fail            = try(var.calico.cleanup_on_fail, null)
  max_history                = try(var.calico.max_history, null)
  atomic                     = try(var.calico.atomic, null)
  skip_crds                  = try(var.calico.skip_crds, null)
  render_subchart_notes      = try(var.calico.render_subchart_notes, null)
  disable_openapi_validation = try(var.calico.disable_openapi_validation, null)
  wait                       = try(var.calico.wait, false)
  wait_for_jobs              = try(var.calico.wait_for_jobs, null)
  dependency_update          = try(var.calico.dependency_update, null)
  replace                    = try(var.calico.replace, null)
  lint                       = try(var.calico.lint, null)

  postrender    = try(var.calico.postrender, [])
  set           = []
  set_sensitive = try(var.calico.set_sensitive, [])

  tags = var.tags
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

################################################################################
# Storage Class config
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
