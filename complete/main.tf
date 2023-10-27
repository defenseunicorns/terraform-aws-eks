resource "random_id" "default" {
  byte_length = 2
}

locals {
  # Add randomness to names to avoid collisions when multiple users are using this example
  vpc_name = "${var.name_prefix}-${lower(random_id.default.hex)}"
  tags = merge(
    var.tags,
    {
      RootTFModule = replace(basename(path.cwd), "_", "-") # tag names based on the directory name
      ManagedBy    = "Terraform"
      Repo         = "https://github.com/defenseunicorns/terraform-aws-uds-vpc"
    }
  )
}


module "vpc" {
  #checkov:skip=CKV_TF_1: using ref to a specific version
  source = "../.."

  name                  = local.vpc_name
  vpc_cidr              = "10.200.0.0/16"
  secondary_cidr_blocks = ["100.64.0.0/16"] # Used for optimizing IP address usage by pods in an EKS cluster. See https://aws.amazon.com/blogs/containers/optimize-ip-addresses-usage-by-pods-in-your-amazon-eks-cluster/
  azs                   = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets        = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k)]
  private_subnets       = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k + 4)]
  database_subnets      = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k + 8)]
  intra_subnets         = [for k, v in module.vpc.azs : cidrsubnet(element(module.vpc.vpc_secondary_cidr_blocks, 0), 5, k)]
  ip_offsets_per_subnet = var.ip_offsets_per_subnet # List of offsets for IP reservations in each subnet.
  single_nat_gateway    = true
  enable_nat_gateway    = true
  private_subnet_tags = {
    # Needed if you are deploying EKS v1.14 or earlier to this VPC. Not needed for EKS v1.15+.
    "kubernetes.io/cluster/my-cluster" = "owned"
    # Needed if you are using EKS with the AWS Load Balancer Controller v2.1.1 or earlier. Not needed if you are using a version of the Load Balancer Controller later than v2.1.1.
    "kubernetes.io/cluster/my-cluster" = "shared"
    # Needed if you are deploying EKS and load balancers to private subnets.
    "kubernetes.io/role/internal-elb" = 1
  }
  public_subnet_tags = {
    # Needed if you are deploying EKS and load balancers to public subnets. Not needed if you are only using private subnets for the EKS cluster.
    "kubernetes.io/role/elb" = 1
  }
  intra_subnet_tags = {
    "foo" = "bar"
  }
  create_database_subnet_group      = true
  instance_tenancy                  = "default"
  vpc_flow_log_permissions_boundary = var.iam_role_permissions_boundary
  tags                              = local.tags
}
