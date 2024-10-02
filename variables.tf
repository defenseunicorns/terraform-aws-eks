# tflint-ignore: terraform_unused_declarations
variable "name" {
  type    = string
  default = ""
}

variable "cluster_name" {
  description = "Name of cluster"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "cluster_tags" {
  description = "A map of additional tags to add to the cluster"
  type        = map(string)
  default     = {}
}

variable "cluster_version" {
  description = "Kubernetes version to use for EKS cluster"
  type        = string
  default     = "1.30"
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
  default     = ["audit", "api", "authenticator"]
}

variable "aws_region" {
  type        = string
  description = "used to create vpc-cni eni config objects when configuring the vpc-cni marketplace addon"
  default     = ""
}

variable "azs" {
  description = "List of names of availability zones to use for subnet configs"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
  default     = []
}

variable "cluster_ip_family" {
  description = "The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. You can only specify an IP family when you create a cluster, changing this value will force a new cluster to be created"
  type        = string
  default     = "ipv4"
}

variable "cluster_service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "attach_cluster_encryption_policy" {
  description = "Indicates whether or not to attach an additional policy for the cluster IAM role to utilize the encryption key provided"
  type        = bool
  default     = true
}

variable "aws_admin_usernames" {
  description = "A list of one or more AWS usernames with authorized access to KMS and EKS resources, will automatically add the user or role running the terraform as an admin"
  type        = list(string)
  default     = []
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the cluster endpoint"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "control_plane_subnet_ids" {
  description = "Subnet IDs for control plane"
  type        = list(string)
  default     = []
}

variable "vpc_cni_custom_subnet" {
  description = "Subnet to put pod ENIs in"
  type        = list(string)
  default     = []
}

variable "create_eni_configs" {
  description = "Merge ENI configs for VPC CNI into cluster_addons configuration"
  type        = bool
  default     = true
}

variable "cluster_additional_security_group_ids" {
  description = "List of additional, externally created security group IDs to attach to the cluster control plane"
  type        = list(string)
  default     = []
}

################################################################################
# Cluster Security Group
################################################################################

variable "create_cluster_security_group" {
  description = "Determines if a security group is created for the cluster. Note: the EKS service creates a primary security group for the cluster by default"
  type        = bool
  default     = true
}

variable "cluster_security_group_id" {
  description = "Existing security group ID to be attached to the cluster"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster security group will be provisioned"
  type        = string
  default     = null
}

variable "cluster_security_group_name" {
  description = "Name to use on cluster security group created"
  type        = string
  default     = null
}

variable "cluster_security_group_use_name_prefix" {
  description = "Determines whether cluster security group name (`cluster_security_group_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "cluster_security_group_description" {
  description = "Description of the cluster security group created"
  type        = string
  default     = "EKS cluster security group"
}

variable "cluster_security_group_additional_rules" {
  description = "List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source"
  type        = any
  default     = {}
}

variable "node_security_group_additional_rules" {
  description = "List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source"
  type        = any
  default     = {}
}

variable "cluster_security_group_tags" {
  description = "A map of additional tags to add to the cluster security group created"
  type        = map(string)
  default     = {}
}

################################################################################
# KMS Key
################################################################################

variable "create_kms_key" {
  description = "Controls if a KMS key for cluster encryption should be created"
  type        = bool
  default     = true
}

variable "kms_key_description" {
  description = "The description of the key as viewed in AWS console"
  type        = string
  default     = null
}

variable "kms_key_deletion_window_in_days" {
  description = "The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between `7` and `30`, inclusive. If you do not specify a value, it defaults to `30`"
  type        = number
  default     = null
}

variable "enable_kms_key_rotation" {
  description = "Specifies whether key rotation is enabled"
  type        = bool
  default     = true
}

variable "kms_key_enable_default_policy" {
  description = "Specifies whether to enable the default key policy"
  type        = bool
  default     = true
}

variable "kms_key_owners" {
  description = "A list of IAM ARNs for those who will have full key permissions (`kms:*`)"
  type        = list(string)
  default     = []
}

variable "kms_key_administrators" {
  description = "A list of IAM ARNs for [key administrators](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-administrators). If no value is provided, the current caller identity is used to ensure at least one key admin is available"
  type        = list(string)
  default     = []
}

variable "kms_key_users" {
  description = "A list of IAM ARNs for [key users](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-users)"
  type        = list(string)
  default     = []
}

variable "kms_key_service_users" {
  description = "A list of IAM ARNs for [key service users](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-service-integration)"
  type        = list(string)
  default     = []
}

variable "kms_key_source_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document. Statements must have unique `sid`s"
  type        = list(string)
  default     = []
}

variable "kms_key_override_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document. In merging, statements with non-blank `sid`s will override statements with the same `sid`"
  type        = list(string)
  default     = []
}

variable "kms_key_aliases" {
  description = "A list of aliases to create. Note - due to the use of `toset()`, values must be static strings and not computed values"
  type        = list(string)
  default     = []
}

#-------------------------------
# Node Groups
#-------------------------------

variable "eks_managed_node_groups" {
  description = "Managed node groups configuration"
  type        = any
  default     = {}
}

variable "self_managed_node_groups" {
  description = "Self-managed node groups configuration"
  type        = any
  default     = {}
}

variable "self_managed_node_group_defaults" {
  description = "Map of self-managed node group default configurations"
  type        = any
  default     = {}
}

variable "eks_managed_node_group_defaults" {
  description = "Map of EKS-managed node group default configurations"
  type        = any
  default     = {}
}

variable "cluster_addons" {
  description = <<-EOD
  Nested of eks native add-ons and their associated parameters.
  See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon for supported values.
  See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/complete/main.tf#L44-L60 for upstream example.

  to see available eks marketplace addons available for your cluster's version run:
  aws eks describe-addon-versions --kubernetes-version $k8s_cluster_version --query 'addons[].{MarketplaceProductUrl: marketplaceInformation.productUrl, Name: addonName, Owner: owner Publisher: publisher, Type: type}' --output table
EOD
  type        = any
  default     = {}
}

variable "create_cluster_primary_security_group_tags" {
  description = "Indicates whether or not to tag the cluster's primary security group. This security group is created by the EKS service, not the module, and therefore tagging is handled after cluster creation"
  type        = bool
  default     = true
}

variable "cluster_timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster"
  type        = map(string)
  default     = {}
}

################################################################################
# CloudWatch Log Group
################################################################################

variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days"
  type        = number
  default     = 90
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_class" {
  description = "Specified the log class of the log group. Possible values are: `STANDARD` or `INFREQUENT_ACCESS`"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_tags" {
  description = "A map of additional tags to add to the cloudwatch log group created"
  type        = map(string)
  default     = {}
}


########################################################
# Blueprints addons configuration
########################################################

variable "create_kubernetes_resources" {
  description = "Create Kubernetes resource with Helm or Kubernetes provider"
  type        = bool
  default     = true
}

variable "blueprints_addons_prefixes" {
  description = "Prefixes for the eks blueprints addons, used to parse addon gitops_metadata output and create objects with"
  type        = list(string)
  default = [
    "cert_manager",
    "cluster_autoscaler",
    "aws_cloudwatch_metrics",
    "aws_efs_csi_driver",
    "aws_fsx_csi_driver",
    "aws_privateca_issuer",
    "external_dns_route53",
    "external_secrets",
    "aws_load_balancer_controller",
    "aws_for_fluentbit",
    "aws_node_termination_handler",
    "karpenter",
    "velero",
    "aws_gateway_api_controller",
    "fargate_fluentbit_log",
  ]
}

variable "create_ssm_parameters" {
  description = "Create SSM parameters for values from eks blueprints addons outputs"
  type        = bool
  default     = true
}

variable "ssm_parameter_kms_key_arn" {
  description = "KMS key arn for use with SSM parameter encryption/decryption"
  type        = string
  default     = ""
}

#----------------AWS EBS CSI Driver-------------------------
variable "enable_amazon_eks_aws_ebs_csi_driver" {
  description = "Enable EKS Managed AWS EBS CSI Driver add-on"
  type        = bool
  default     = false
}

variable "enable_gp3_default_storage_class" {
  description = "Enable gp3 as default storage class"
  type        = bool
  default     = false
}

variable "ebs_storageclass_reclaim_policy" {
  description = "Reclaim policy for gp3 storage class, valid options are Delete and Retain"
  type        = string
  default     = "Delete"
}

#----------------AWS EFS CSI Driver-------------------------
variable "enable_amazon_eks_aws_efs_csi_driver" {
  description = "Enable EFS CSI Driver add-on"
  type        = bool
  default     = false
}

variable "efs_storageclass_reclaim_policy" {
  description = "Reclaim policy for EFS storage class, valid options are Delete and Retain"
  type        = string
  default     = "Delete"
}

variable "efs_vpc_cidr_blocks" {
  description = "CIDR blocks to allow access to EFS"
  type        = list(string)
  default     = []
}

#----------------Metrics Server-------------------------
variable "enable_metrics_server" {
  description = "Enable metrics server add-on"
  type        = bool
  default     = false
}

variable "metrics_server" {
  description = "Metrics Server config for aws-ia/eks-blueprints-addon/aws"
  type        = any
  default     = {}
}

#----------------AWS Node Termination Handler-------------------------
variable "enable_aws_node_termination_handler" {
  description = "Enable AWS Node Termination Handler add-on"
  type        = bool
  default     = false
}

variable "aws_node_termination_handler" {
  description = "AWS Node Termination Handler config for aws-ia/eks-blueprints-addon/aws"
  type        = any
  default     = {}
}
#----------------Cluster Autoscaler-------------------------
variable "enable_cluster_autoscaler" {
  description = "Enable Cluster autoscaler add-on"
  type        = bool
  default     = false
}

variable "cluster_autoscaler" {
  description = "Cluster Autoscaler config for aws-ia/eks-blueprints-addon/aws"
  type        = any
  default = {
    set = [
      {
        name  = "extraArgs.expander"
        value = "priority"
      },
      {
        name  = "expanderPriorities"
        value = <<-EOT
                  100:
                    - .*-spot-2vcpu-8mem.*
                  90:
                    - .*-spot-4vcpu-16mem.*
                  10:
                    - .*
                EOT
      }
    ]
  }
}

#----------------AWS Loadbalancer Controller-------------------------
variable "enable_aws_load_balancer_controller" {
  description = "Enable AWS Loadbalancer Controller add-on"
  type        = bool
  default     = false
}

variable "aws_load_balancer_controller" {
  description = "AWS Loadbalancer Controller config for aws-ia/eks-blueprints-addon/aws"
  type        = any
  default     = {}
}

#----------------k8s Secret Store CSI Driver-------------------------
variable "enable_secrets_store_csi_driver" {
  description = "Enable k8s Secret Store CSI Driver add-on"
  type        = bool
  default     = false
}

variable "secrets_store_csi_driver" {
  description = "k8s Secret Store CSI Driver config for aws-ia/eks-blueprints-addon/aws"
  type        = any
  default     = {}
}

#----------------External Secrets-------------------------

variable "enable_external_secrets" {
  description = "Enable External Secrets add-on"
  type        = bool
  default     = false
}

variable "external_secrets" {
  description = "External Secrets config for aws-ia/eks-blueprints-addon/aws"
  type        = any
  default     = {}
}

variable "external_secrets_ssm_parameter_arns" {
  description = "List of Systems Manager Parameter ARNs that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = [] # if not defined, ["arn:$partition:ssm:*:*:parameter/*"]
}

variable "external_secrets_secrets_manager_arns" {
  description = "List of Secrets Manager ARNs that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = [] # if not defined, ["arn:$partition:secretsmanager:*:*:secret:*"]
}

variable "external_secrets_kms_key_arns" {
  description = "List of KMS Key ARNs that are used by Secrets Manager that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = [] # if not defined, ["arn:$partition:kms:*:*:key/*"]
}

#----------------Karpenter-------------------------
variable "enable_karpenter" {
  description = "Enable Karpenter add-on"
  type        = bool
  default     = false
}

variable "karpenter" {
  description = "Karpenter config for aws-ia/eks-blueprints-addon/aws"
  type        = any
  default     = {}
}

#----------------Bottlerocket Update Operator-------------------------
variable "enable_bottlerocket_update_operator" {
  description = "Enable Bottlerocket and Bottlerocket Update Operator add-on"
  type        = bool
  default     = false
}

variable "bottlerocket_shadow" {
  description = "Bottlerocket Shadow config for aws-ia/eks-blueprints-addon/aws"
  type        = any
  default     = {}
}

variable "bottlerocket_update_operator" {
  description = "Bottlerocket Update Operator config for aws-ia/eks-blueprints-addon/aws"
  type        = any
  default     = {}
}

#----------------AWS Cloudwatch Metrics-------------------------
variable "enable_aws_cloudwatch_metrics" {
  description = "Enable AWS Cloudwatch Metrics add-on"
  type        = bool
  default     = false
}

variable "aws_cloudwatch_metrics" {
  description = "AWS Cloudwatch Metrics config for aws-ia/eks-blueprints-addon/aws"
  type        = any
  default     = {}
}

#aws_fsx_csi_driver
#----------------AWS FSX CSI Driver-------------------------
variable "enable_aws_fsx_csi_driver" {
  description = "Enable FSX CSI Driver add-on"
  type        = bool
  default     = false
}

variable "aws_fsx_csi_driver" {
  description = "FSX CSI Driver config for aws-ia/eks-blueprints-addon/aws"
  type        = any
  default     = {}
}

#----------------AWS Private CA Issuer-------------------------
variable "enable_aws_privateca_issuer" {
  description = "Enable AWS Private CA Issuer add-on"
  type        = bool
  default     = false
}

variable "aws_privateca_issuer" {
  description = "AWS Private CA Issuer config for aws-ia/eks-blueprints-addon/aws"
  type        = any
  default     = {}
}

#----------------Cert Manager-------------------------
variable "enable_cert_manager" {
  description = "Enable Cert Manager add-on"
  type        = bool
  default     = false
}

variable "cert_manager" {
  description = "Cert Manager config for aws-ia/eks-blueprints-addon/aws"
  type        = any
  default     = {}
}

variable "cert_manager_route53_hosted_zone_arns" {
  description = "List of Route53 Hosted Zone ARNs that are used by cert-manager to create DNS records"
  type        = list(string)
  default     = [] # if not defined, ["arn:$partition:route53:*:*:hostedzone/*"]
}

#----------------External DNS-------------------------
variable "enable_external_dns" {
  description = "Enable External DNS add-on"
  type        = bool
  default     = false
}

variable "external_dns" {
  description = "External DNS config for aws-ia/eks-blueprints-addon/aws"
  type        = any
  default     = {}
}

# cluster access
#----------------Access Entry-------------------------
variable "access_entries" {
  description = "Map of access entries to add to the cluster"
  type        = any
  default     = {}
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via access entry"
  type        = bool
  default     = true
}

variable "authentication_mode" {
  description = "The authentication mode for the cluster. Valid values are `CONFIG_MAP`, `API` or `API_AND_CONFIG_MAP`"
  type        = string
  default     = "API_AND_CONFIG_MAP"
}

variable "bastion_role_arn" {
  description = "The ARN of the IAM role to assume when connecting to the bastion host"
  type        = string
  default     = ""
}

variable "additional_access_entries" {
  description = "A list of one or more roles with authorized access to KMS and EKS resources"
  type        = list(string)
}
