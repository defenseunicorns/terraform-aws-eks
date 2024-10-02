
# Region used for Terratest
output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "efs_storageclass_name" {
  description = "The name of the EFS storageclass that was created (if var.enable_amazon_eks_aws_efs_csi_driver was set to true)"
  value       = try(kubernetes_storage_class_v1.efs[0].id, null)
}

################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.aws_eks.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.aws_eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.aws_eks.cluster_endpoint
}

output "cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = module.aws_eks.cluster_id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.aws_eks.cluster_name
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.aws_eks.cluster_oidc_issuer_url
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = module.aws_eks.cluster_version
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = module.aws_eks.cluster_platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
  value       = module.aws_eks.cluster_status
}

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = module.aws_eks.cluster_primary_security_group_id
}

output "cluster_service_cidr" {
  description = "The CIDR block where Kubernetes pod and service IP addresses are assigned from"
  value       = module.aws_eks.cluster_service_cidr
}

output "cluster_ip_family" {
  description = "The IP family used by the cluster (e.g. `ipv4` or `ipv6`)"
  value       = module.aws_eks.cluster_ip_family
}

################################################################################
# Access Entry
################################################################################

output "access_entries" {
  description = "Map of access entries created and their attributes"
  value       = module.aws_eks.access_entries
}

output "access_policy_associations" {
  description = "Map of eks cluster access policy associations created and their attributes"
  value       = module.aws_eks.access_policy_associations
}

################################################################################
# KMS Key
################################################################################

output "kms_key_arn" {
  description = "The Amazon Resource Name (ARN) of the key"
  value       = module.aws_eks.kms_key_arn
}

output "kms_key_id" {
  description = "The globally unique identifier for the key"
  value       = module.aws_eks.kms_key_id
}

output "kms_key_policy" {
  description = "The IAM resource policy set on the key"
  value       = module.aws_eks.kms_key_policy
}

################################################################################
# Cluster Security Group
################################################################################

output "cluster_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the cluster security group"
  value       = module.aws_eks.cluster_security_group_arn
}

output "cluster_security_group_id" {
  description = "ID of the cluster security group"
  value       = module.aws_eks.cluster_security_group_id
}

################################################################################
# Node Security Group
################################################################################

output "node_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the node shared security group"
  value       = module.aws_eks.node_security_group_arn
}

output "node_security_group_id" {
  description = "ID of the node shared security group"
  value       = module.aws_eks.node_security_group_id
}

################################################################################
# IRSA
################################################################################

output "oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = module.aws_eks.oidc_provider
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = module.aws_eks.oidc_provider_arn
}

output "cluster_tls_certificate_sha1_fingerprint" {
  description = "The SHA1 fingerprint of the public key of the cluster's certificate"
  value       = module.aws_eks.cluster_tls_certificate_sha1_fingerprint
}

################################################################################
# IAM Role
################################################################################

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster"
  value       = module.aws_eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.aws_eks.cluster_iam_role_arn
}

output "cluster_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.aws_eks.cluster_iam_role_unique_id
}

################################################################################
# EKS Addons
################################################################################

output "cluster_addons" {
  description = "Map of attribute maps for all EKS cluster addons enabled"
  value       = module.aws_eks.cluster_addons
}

################################################################################
# EKS Identity Provider
################################################################################

output "cluster_identity_providers" {
  description = "Map of attribute maps for all EKS identity providers enabled"
  value       = module.aws_eks.cluster_identity_providers
}

################################################################################
# CloudWatch Log Group
################################################################################

output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = module.aws_eks.cloudwatch_log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "Arn of cloudwatch log group created"
  value       = module.aws_eks.cloudwatch_log_group_arn
}

################################################################################
# EKS Managed Node Group
################################################################################

output "eks_managed_node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created"
  value       = module.aws_eks.eks_managed_node_groups
}

output "eks_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by EKS managed node groups"
  value       = module.aws_eks.eks_managed_node_groups_autoscaling_group_names
}

################################################################################
# Self Managed Node Group
################################################################################

output "self_managed_node_groups" {
  description = "Map of attribute maps for all self managed node groups created"
  value       = module.aws_eks.self_managed_node_groups
}

output "self_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by self-managed node groups"
  value       = module.aws_eks.self_managed_node_groups_autoscaling_group_names
}

################################################################################
# EKS Addons metadata
################################################################################
# see https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/main/outputs.tf#L167-L276
output "eks_addons_gitops_metadata" {
  description = ""
  value       = try(module.eks_blueprints_kubernetes_addons.gitops_metadata, null)
}

output "nlb_sg_id" {
  value     = aws_security_group.nlb_sg.id
}
