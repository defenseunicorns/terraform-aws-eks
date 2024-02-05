data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}


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
  bastion_name               = "${var.name_prefix}-bastion-${lower(random_id.default.hex)}"
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
  azs = [for az_name in slice(data.aws_availability_zones.available.names, 0, min(length(data.aws_availability_zones.available.names), var.num_azs)) : az_name]
}

module "vpc" {
  source = "git::https://github.com/defenseunicorns/terraform-aws-vpc.git?ref=v0.1.5"

  name                  = local.vpc_name
  vpc_cidr              = var.vpc_cidr
  secondary_cidr_blocks = var.secondary_cidr_blocks
  azs                   = local.azs
  public_subnets        = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k)]
  private_subnets       = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k + 4)]
  database_subnets      = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k + 8)]
  intra_subnets         = [for k, v in module.vpc.azs : cidrsubnet(element(module.vpc.vpc_secondary_cidr_blocks, 0), 5, k)]
  single_nat_gateway    = true
  enable_nat_gateway    = true

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
# Bastion instance
################################################################################
locals {
  ingress_bastion_to_cluster = {
    description              = "Bastion SG to Cluster"
    security_group_id        = module.eks.cluster_security_group_id
    from_port                = 443
    to_port                  = 443
    protocol                 = "tcp"
    type                     = "ingress"
    source_security_group_id = try(module.bastion[0].security_group_ids[0], null)
  }

}

data "aws_ami" "amazonlinux2" {
  count = var.enable_bastion ? 1 : 0

  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*x86_64-gp2"]
  }

  owners = ["amazon"]
}

module "bastion" {
  source = "git::https://github.com/defenseunicorns/terraform-aws-bastion.git?ref=v0.0.11"

  count = var.enable_bastion ? 1 : 0

  enable_bastion_terraform_permissions = true

  ami_id        = data.aws_ami.amazonlinux2[0].id
  instance_type = var.bastion_instance_type
  root_volume_config = {
    volume_type = "gp3"
    volume_size = "20"
    encrypted   = true
  }
  name                           = local.bastion_name
  vpc_id                         = module.vpc.vpc_id
  subnet_id                      = module.vpc.private_subnets[0]
  region                         = var.region
  access_logs_bucket_name        = aws_s3_bucket.access_log_bucket.id
  session_log_bucket_name_prefix = "${local.bastion_name}-sessionlogs"
  kms_key_arn                    = aws_kms_key.default.arn
  ssh_user                       = var.bastion_ssh_user
  ssh_password                   = var.bastion_ssh_password
  assign_public_ip               = false
  enable_log_to_s3               = true
  enable_log_to_cloudwatch       = true
  tenancy                        = var.bastion_tenancy
  zarf_version                   = var.zarf_version
  permissions_boundary           = var.iam_role_permissions_boundary
  tags = merge(
    local.tags,
  { Function = "bastion-ssm" })
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
  cluster_security_group_additional_rules = merge(
    var.enable_bastion ? { ingress_bastion_to_cluster = local.ingress_bastion_to_cluster } : {},
    #other rules here
  )
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

    placement = {
      tenancy = var.eks_worker_tenancy
    }

    post_userdata = <<-EOT
        echo "Bootstrap successfully completed! You can further apply config or install to run after bootstrap if needed"
      EOT

    # bootstrap_extra_args used only when you pass custom_ami_id. Allows you to change the Container Runtime for Nodes
    # e.g., bootstrap_extra_args="--use-max-pods false --container-runtime containerd"
    bootstrap_extra_args = "--use-max-pods false"

    iam_role_additional_policies = {
      AmazonElasticFileSystemFullAccess = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonElasticFileSystemFullAccess"
    }

    # enable discovery of autoscaling groups by cluster-autoscaler
    autoscaling_group_tags = merge(
      local.tags,
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
      subnet_type = "private",
      cluster     = local.cluster_name
    }
  }

  mission_app_self_mg_node_group = {
    bigbang_ng = {
      platform      = "bottlerocket"
      ami_id        = data.aws_ami.eks_default_bottlerocket.id
      instance_type = "m5d.2xlarge" # conflicts with instance_requirements settings
      min_size      = 3
      max_size      = 5
      desired_size  = 3
      key_name      = module.key_pair.key_pair_name

      bootstrap_extra_args = <<-EOT
        # The admin host container provides SSH access and runs with "superpowers".
        # It is disabled by default, but can be disabled explicitly.
        [settings.host-containers.admin]
        enabled = false

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
        # label2 = "bb-core"

        [settings.kubernetes.node-taints]
        # dedicated = "experimental:PreferNoSchedule"
        # special = "true:NoSchedule"
      EOT
    }
  }

  self_managed_node_groups = var.enable_self_managed_nodegroups ? local.mission_app_self_mg_node_group : {}
  access_entries = merge(
    var.access_entries,
    var.enable_bastion ? {
      bastion = {
        principal_arn = module.bastion[0].bastion_role_arn
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
    } : {}
  )
}

module "ssm_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 2.0"

  create = var.create_ssm_parameters

  description = "KMS key for SecureString SSM parameters"

  key_administrators = [
    data.aws_caller_identity.current.arn
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
  ssm_parameter_key_arn = var.create_ssm_parameters ? module.ssm_kms_key.key_arn : ""
}

module "eks" {
  source = "../.."

  name                                    = local.cluster_name
  aws_region                              = var.region
  vpc_id                                  = module.vpc.vpc_id
  private_subnet_ids                      = module.vpc.private_subnets
  control_plane_subnet_ids                = module.vpc.private_subnets
  iam_role_permissions_boundary           = var.iam_role_permissions_boundary
  cluster_security_group_additional_rules = local.cluster_security_group_additional_rules
  cluster_endpoint_public_access          = var.cluster_endpoint_public_access
  cluster_endpoint_private_access         = true
  vpc_cni_custom_subnet                   = module.vpc.intra_subnets
  azs                                     = module.vpc.azs
  aws_admin_usernames                     = var.aws_admin_usernames
  cluster_version                         = var.cluster_version
  cidr_blocks                             = module.vpc.private_subnets_cidr_blocks
  eks_use_mfa                             = var.eks_use_mfa
  dataplane_wait_duration                 = var.dataplane_wait_duration

  ######################## EKS Managed Node Group ###################################
  eks_managed_node_group_defaults = local.eks_managed_node_group_defaults
  eks_managed_node_groups         = local.eks_managed_node_groups

  ######################## Self Managed Node Group ###################################
  self_managed_node_group_defaults = local.self_managed_node_group_defaults
  self_managed_node_groups         = local.self_managed_node_groups

  tags = local.tags

  access_entries      = local.access_entries
  authentication_mode = var.authentication_mode
  #---------------------------------------------------------------
  #"native" EKS Add-Ons
  #---------------------------------------------------------------

  cluster_addons = var.cluster_addons

  #---------------------------------------------------------------
  # EKS Blueprints - blueprints curated helm charts
  #---------------------------------------------------------------

  create_kubernetes_resources = var.create_kubernetes_resources
  create_ssm_parameters       = var.create_ssm_parameters
  ssm_parameter_key_arn       = local.ssm_parameter_key_arn

  # AWS EKS EBS CSI Driver
  enable_amazon_eks_aws_ebs_csi_driver = var.enable_amazon_eks_aws_ebs_csi_driver
  enable_gp3_default_storage_class     = var.enable_gp3_default_storage_class
  storageclass_reclaim_policy          = var.storageclass_reclaim_policy

  # AWS EKS EFS CSI Driver
  enable_amazon_eks_aws_efs_csi_driver = var.enable_amazon_eks_aws_efs_csi_driver
  aws_efs_csi_driver                   = var.aws_efs_csi_driver

  reclaim_policy = var.reclaim_policy

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
}

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~> 2.0"

  key_name_prefix    = local.cluster_name
  create_private_key = true

  tags = local.tags
}

module "ebs_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 2.0"

  description = "Customer managed key to encrypt EKS managed node group volumes"

  # Policy
  key_administrators = [
    data.aws_caller_identity.current.arn
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
