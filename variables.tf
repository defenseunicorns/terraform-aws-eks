# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of cluster"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "Kubernetes version to use for EKS cluster"
  type        = string
  default     = "1.29"
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
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

variable "aws_region" {
  type    = string
  default = ""
}

variable "name" {
  type    = string
  default = ""
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "kms_key_administrators" {
  description = "List of ARNs of additional administrator users to add to KMS key policy"
  type        = list(string)
  default     = []
}

variable "aws_admin_usernames" {
  description = "A list of one or more AWS usernames with authorized access to KMS and EKS resources, will automatically add the user running the terraform as an admin"
  type        = list(string)
  default     = []
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to the cluster endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the cluster endpoint"
  type        = bool
  default     = false
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

variable "cluster_security_group_additional_rules" {
  description = "List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source"
  type        = any
  default     = {}
}

variable "dataplane_wait_duration" {
  description = "Duration to wait after the EKS cluster has become active before creating the dataplane components (EKS managed nodegroup(s), self-managed nodegroup(s), Fargate profile(s))"
  type        = string
  default     = "4m"
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
