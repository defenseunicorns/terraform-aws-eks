# Root module outputs
# Setting all of them sensitive = true to avoid having their details logged to the console in our public CI pipelines
output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
  sensitive   = true
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
  sensitive   = true
}

output "efs_storageclass_name" {
  description = "The name of the EFS storageclass that was created (if var.enable_amazon_eks_aws_efs_csi_driver was set to true)"
  value       = try(module.eks.efs_storageclass_name, null)
}
