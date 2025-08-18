data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}
data "aws_iam_session_context" "current" {
  # This data source provides information on the IAM source role of an STS assumed role
  # For non-role ARNs, this data source simply passes the ARN through issuer ARN
  # Ref https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2327#issuecomment-1355581682
  # Ref https://github.com/hashicorp/terraform-provider-aws/issues/28381
  arn = data.aws_caller_identity.current.arn
}



data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}


resource "random_id" "default" {
  byte_length = 2
}

locals {
  vpc_name                   = "${var.name_prefix}-${lower(random_id.default.hex)}"
  cluster_name               = "${var.name_prefix}-${lower(random_id.default.hex)}"
  access_logging_name_prefix = "${var.name_prefix}-accesslog-${lower(random_id.default.hex)}"
  kms_key_alias_name_prefix  = "alias/${var.name_prefix}-${lower(random_id.default.hex)}"
  access_log_sqs_queue_name  = "${var.name_prefix}-accesslog-access-${lower(random_id.default.hex)}"
  tags = merge(
    var.tags,
    {
      RootTFModule = replace(basename(path.cwd), "_", "-") # tag names based on the directory name
      ManagedBy    = "Terraform"
      Repo         = "https://github.com/defenseunicorns/terraform-aws-eks"
    }
  )
}

################################################################################
# VPC
################################################################################

locals {
  azs              = [for az_name in slice(data.aws_availability_zones.available.names, 0, min(length(data.aws_availability_zones.available.names), var.num_azs)) : az_name]
  public_subnets   = [for k, v in module.subnet_addrs.network_cidr_blocks : v if strcontains(k, "public")]
  private_subnets  = [for k, v in module.subnet_addrs.network_cidr_blocks : v if strcontains(k, "private")]
  database_subnets = [for k, v in module.subnet_addrs.network_cidr_blocks : v if strcontains(k, "database")]
}

module "subnet_addrs" {
  source = "git::https://github.com/hashicorp/terraform-cidr-subnets?ref=v1.0.0"

  base_cidr_block = var.vpc_cidr
  networks        = var.vpc_subnets
}

module "vpc" {
  source = "git::https://github.com/defenseunicorns/terraform-aws-vpc.git?ref=v0.1.13"

  name                         = local.vpc_name
  vpc_cidr                     = var.vpc_cidr
  secondary_cidr_blocks        = var.secondary_cidr_blocks
  azs                          = local.azs
  public_subnets               = local.public_subnets
  private_subnets              = local.private_subnets
  database_subnets             = local.database_subnets
  intra_subnets                = [for k, v in module.vpc.azs : cidrsubnet(element(module.vpc.vpc_secondary_cidr_blocks, 0), 5, k)]
  single_nat_gateway           = true #remove if in a private VPC behind TGW
  enable_nat_gateway           = true #remove if in a private VPC behind TGW
  create_default_vpc_endpoints = var.create_default_vpc_endpoints

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
  create_database_subnet_group = true

  instance_tenancy                  = "default"
  vpc_flow_log_permissions_boundary = var.iam_role_permissions_boundary

  tags = local.tags
}

################################################################################
# EKS Cluster
################################################################################

data "aws_ami" "eks_default_bottlerocket" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["bottlerocket-aws-k8s-${var.cluster_version}-x86_64-*"]
  }
}

locals {
  eks_managed_node_group_defaults = {
    # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/node_groups.tf
    iam_role_permissions_boundary = var.iam_role_permissions_boundary
    ami_type                      = "AL2_x86_64"
    instance_types                = ["m5a.large", "m5.large", "m6i.large"]
    tags = {
      subnet_type = "private",
      cluster     = local.cluster_name
    }
  }

  mission_app_mg_node_group = {
    managed_ng1 = {
      min_size     = 2
      max_size     = 2
      desired_size = 2
      disk_size    = 50
    }
  }

  eks_managed_node_groups = merge(
    var.enable_eks_managed_nodegroups ? local.mission_app_mg_node_group : {},
    # var.enable_eks_managed_nodegroups && var.keycloak_enabled ? local.keycloak_mg_node_group : {}
  )

  self_managed_node_group_defaults = {
    iam_role_permissions_boundary          = var.iam_role_permissions_boundary
    instance_type                          = null
    update_launch_template_default_version = true
    use_mixed_instances_policy             = true

    instance_requirements = {
      allowed_instance_types = ["m6i.4xlarge", "m5a.4xlarge", "m7i-flex.4xlarge"] #this should be adjusted to the appropriate instance family if reserved instances are being utilized
      memory_mib = {
        min = 64000
      }
      vcpu_count = {
        min = 16
      }
    }

    placement = {
      tenancy = var.eks_worker_tenancy
    }

    # bootstrap_extra_args used only when you pass custom_ami_id. Allows you to change the Container Runtime for Nodes
    # e.g., bootstrap_extra_args="--use-max-pods false --container-runtime containerd"
    bootstrap_extra_args = "--use-max-pods false"

    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore      = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore",
      AmazonElasticFileSystemFullAccess = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonElasticFileSystemFullAccess"
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

  uds_core_self_mg_node_group = {
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

  self_managed_node_groups = var.enable_self_managed_nodegroups ? local.uds_core_self_mg_node_group : null

  vpc_cni_addon_irsa_extra_config = {
    "vpc-cni" = merge(
      var.cluster_addons["vpc-cni"],
      {
        service_account_role_arn = module.vpc_cni_ipv4_irsa_role.iam_role_arn
      }
    )
  }

  cluster_addons = merge(
    var.cluster_addons,
    local.vpc_cni_addon_irsa_extra_config
  )
}

module "ssm_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.0"

  create = var.create_ssm_parameters

  description = "KMS key for SecureString SSM parameters"

  key_administrators = [
    data.aws_iam_session_context.current.issuer_arn
  ]

  computed_aliases = {
    ssm = {
      name = "${local.kms_key_alias_name_prefix}-ssm"
    }
  }

  key_statements = [
    {
      sid    = "SSM service access"
      effect = "Allow"
      principals = [
        {
          type        = "Service"
          identifiers = ["ssm.amazonaws.com"]
        }
      ]
      actions = [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
      ]
      resources = ["*"]
    }
  ]

  tags = local.tags
}

locals {
  ssm_parameter_kms_key_arn = var.create_ssm_parameters ? module.ssm_kms_key.key_arn : ""
}

module "eks" {
  source = "../.."

  name                            = local.cluster_name
  aws_region                      = var.region
  vpc_id                          = module.vpc.vpc_id
  private_subnet_ids              = module.vpc.private_subnets
  control_plane_subnet_ids        = module.vpc.private_subnets
  iam_role_permissions_boundary   = var.iam_role_permissions_boundary
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = true
  vpc_cni_custom_subnet           = module.vpc.intra_subnets
  azs                             = module.vpc.azs
  aws_admin_usernames             = var.aws_admin_usernames
  cluster_version                 = var.cluster_version
  dataplane_wait_duration         = var.dataplane_wait_duration

  ######################## EKS Managed Node Group ###################################
  eks_managed_node_group_defaults = local.eks_managed_node_group_defaults
  eks_managed_node_groups         = local.eks_managed_node_groups

  ######################## Self Managed Node Group ###################################
  self_managed_node_group_defaults = local.self_managed_node_group_defaults
  self_managed_node_groups         = local.self_managed_node_groups

  tags = local.tags

  access_entries      = var.access_entries
  authentication_mode = var.authentication_mode

  #---------------------------------------------------------------
  # "native" EKS Marketplace Add-Ons
  #---------------------------------------------------------------

  cluster_addons = local.cluster_addons

  # AWS EKS EBS CSI Driver
  enable_amazon_eks_aws_ebs_csi_driver = var.enable_amazon_eks_aws_ebs_csi_driver
  enable_gp3_default_storage_class     = var.enable_gp3_default_storage_class
  ebs_storageclass_reclaim_policy      = var.ebs_storageclass_reclaim_policy

  # AWS EKS EFS CSI Driver
  enable_amazon_eks_aws_efs_csi_driver = var.enable_amazon_eks_aws_efs_csi_driver
  efs_vpc_cidr_blocks                  = module.vpc.private_subnets_cidr_blocks
  efs_storageclass_reclaim_policy      = var.efs_storageclass_reclaim_policy

  #---------------------------------------------------------------
  # EKS Blueprints - blueprints curated helm charts
  #---------------------------------------------------------------

  create_kubernetes_resources = var.create_kubernetes_resources
  create_ssm_parameters       = var.create_ssm_parameters
  ssm_parameter_kms_key_arn   = local.ssm_parameter_kms_key_arn

  # AWS EKS node termination handler
  enable_aws_node_termination_handler = var.enable_aws_node_termination_handler
  aws_node_termination_handler        = var.aws_node_termination_handler

  # k8s Metrics Server
  enable_metrics_server = var.enable_metrics_server
  metrics_server        = var.metrics_server

  # k8s Cluster Autoscaler
  enable_cluster_autoscaler = var.enable_cluster_autoscaler
  cluster_autoscaler        = var.cluster_autoscaler

  # AWS Load Balancer Controller
  enable_aws_load_balancer_controller = var.enable_aws_load_balancer_controller
  aws_load_balancer_controller        = var.aws_load_balancer_controller

  # k8s Secrets Store CSI Driver
  enable_secrets_store_csi_driver = var.enable_secrets_store_csi_driver
  secrets_store_csi_driver        = var.secrets_store_csi_driver

  # External Secrets
  enable_external_secrets               = var.enable_external_secrets
  external_secrets                      = var.external_secrets
  external_secrets_ssm_parameter_arns   = var.external_secrets_ssm_parameter_arns
  external_secrets_secrets_manager_arns = var.external_secrets_secrets_manager_arns
  external_secrets_kms_key_arns         = var.external_secrets_kms_key_arns


  # Karpenter
  enable_karpenter = var.enable_karpenter
  karpenter        = var.karpenter

  # Bottlerocket update operator
  enable_bottlerocket_update_operator = var.enable_bottlerocket_update_operator
  bottlerocket_update_operator        = var.bottlerocket_update_operator
  bottlerocket_shadow                 = var.bottlerocket_shadow

  # AWS Cloudwatch Metrics
  enable_aws_cloudwatch_metrics = var.enable_aws_cloudwatch_metrics
  aws_cloudwatch_metrics        = var.aws_cloudwatch_metrics

  # AWS FSX CSI Driver
  enable_aws_fsx_csi_driver = var.enable_aws_fsx_csi_driver
  aws_fsx_csi_driver        = var.aws_fsx_csi_driver

  # AWS Private CA Issuer
  enable_aws_privateca_issuer = var.enable_aws_privateca_issuer
  aws_privateca_issuer        = var.aws_privateca_issuer

  # Cert Manager
  enable_cert_manager                   = var.enable_cert_manager
  cert_manager                          = var.cert_manager
  cert_manager_route53_hosted_zone_arns = var.cert_manager_route53_hosted_zone_arns

  # External DNS
  enable_external_dns = var.enable_external_dns
  external_dns        = var.external_dns
}

module "ebs_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.0"

  description = "Customer managed key to encrypt EKS managed node group volumes"

  # Policy
  key_administrators = [
    data.aws_iam_session_context.current.issuer_arn
  ]

  key_service_roles_for_autoscaling = [
    # required for the ASG to manage encrypted volumes for nodes
    "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
    # required for the cluster / persistentvolume-controller to create encrypted PVCs
    module.eks.cluster_iam_role_arn,
  ]

  # Aliases
  aliases                 = ["eks/keycloak_ng_sso/ebs"]
  aliases_use_name_prefix = true

  tags = local.tags
}

resource "aws_iam_policy" "additional" {
  # checkov:skip=CKV_AWS_355: todo reduce resources on policy

  name        = "${local.cluster_name}-additional"
  description = "Example usage of node additional policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = local.tags
}

######################################################
# EKS Self Managed Node Group Dependencies
######################################################
module "self_managed_node_group_keypair" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-key-pair?ref=v2.0.3"

  key_name_prefix    = "${local.cluster_name}-self-managed-ng-"
  create_private_key = true

  tags = local.tags
}

module "self_managed_node_group_secret_key_secrets_manager_secret" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-secrets-manager.git?ref=v1.3.1"

  name                    = module.self_managed_node_group_keypair.key_pair_name
  description             = "Secret key for self managed node group keypair"
  recovery_window_in_days = 0 # 0 - no recovery window, delete immediately when deleted

  block_public_policy = true

  ignore_secret_changes = true
  secret_string         = module.self_managed_node_group_keypair.private_key_openssh

  tags = local.tags
}

######################################################
# vpc-cni irsa role
######################################################
module "vpc_cni_ipv4_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"

  role_name_prefix      = "${module.eks.cluster_name}-vpc-cni-"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  # extra policy to attach to the role
  role_policy_arns = {
    vpc_cni_logging = aws_iam_policy.vpc_cni_logging.arn
  }

  tags = local.tags
}

resource "aws_iam_policy" "vpc_cni_logging" {
  # checkov:skip=CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  # checkov:skip=CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints"
  name        = join("-", compact([var.name_prefix, "vpc-cni-logging", lower(random_id.default.hex)]))
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

  tags = local.tags
}
