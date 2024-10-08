# tflint-ignore: terraform_unused_declarations
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

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "aws_admin_usernames" {
  description = "A list of one or more AWS usernames with authorized access to KMS and EKS resources, will automatically add the user or role running the terraform as an admin"
  type        = list(string)
  default     = []
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

variable "sg_rules" {
  description = "Map of ELB IDs to ports and their CIDR blocks. Enables custom NLB security groups to be created."
  type = map(object({
    ports = map(list(string))  # port (as string) => list of CIDR blocks
  }))
  default = {}
}

################################################################################
# KMS Key
################################################################################

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

################################################################################
# CloudWatch Log Group
################################################################################

variable "cloudwatch_log_group_kms_key_id" {
  description = "If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)"
  type        = string
  default     = null
}

########################################################
# Blueprints addons configuration
########################################################

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

#----------------AWS Node Termination Handler-------------------------
variable "enable_aws_node_termination_handler" {
  description = "Enable AWS Node Termination Handler add-on"
  type        = bool
  default     = false
}

#----------------Cluster Autoscaler-------------------------
variable "enable_cluster_autoscaler" {
  description = "Enable Cluster autoscaler add-on"
  type        = bool
  default     = false
}

#----------------k8s Secret Store CSI Driver-------------------------
variable "enable_secrets_store_csi_driver" {
  description = "Enable k8s Secret Store CSI Driver add-on"
  type        = bool
  default     = false
}

#----------------External Secrets-------------------------

variable "enable_external_secrets" {
  description = "Enable External Secrets add-on"
  type        = bool
  default     = false
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

#----------------AWS Cloudwatch Metrics-------------------------
variable "enable_aws_cloudwatch_metrics" {
  description = "Enable AWS Cloudwatch Metrics add-on"
  type        = bool
  default     = false
}

#aws_fsx_csi_driver
#----------------AWS FSX CSI Driver-------------------------
variable "enable_aws_fsx_csi_driver" {
  description = "Enable FSX CSI Driver add-on"
  type        = bool
  default     = false
}

#----------------AWS Private CA Issuer-------------------------
variable "enable_aws_privateca_issuer" {
  description = "Enable AWS Private CA Issuer add-on"
  type        = bool
  default     = false
}

#----------------Cert Manager-------------------------
variable "enable_cert_manager" {
  description = "Enable Cert Manager add-on"
  type        = bool
  default     = false
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
  default =   []
}
