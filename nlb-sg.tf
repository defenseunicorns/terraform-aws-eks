# local block intended for static values
locals {

  mde_egress_cidrs = [
    # MDE public IPs
  ]

  idp_public_ips = [
    # Keycloak IdP public IPs
  ]

}

resource "aws_security_group" "keycloak_sg" {
  # checkov:skip=CKV2_AWS_5: "false positive" -- this resource is only created for staging and prod based on the vpc_configs

  # Naming convention for the security group.
  name        = "${local.cluster_name}-${var.kc_sg_name}-${each.value.sg_index + 1}"
  description = "Security group for Keycloak with ingress rules"
  # Retrieve the VPC ID from the vpc module using the vpc_name.
  vpc_id = var.vpc_id

  # Dynamically create ingress rules based on the allow_list for each security group.
  dynamic "ingress" {
    for_each = each.value.allow_list
    content {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
      description = "HTTPS ingress for Keycloak"
    }
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP ingress from VPC"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS ingress from VPC"
  }

  ingress {
    from_port   = 15021
    to_port     = 15021
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
    description = "Custom port ingress from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    description = "Egress All from VPC"
  }
}

resource "aws_security_group" "tenant_sg" {
  # checkov:skip=CKV2_AWS_5: "false positive" -- this resource is only created for staging and prod based on the vpc_configs

  # Use a combination of vpc_name and sg_index to uniquely identify each security group in the for_each loop.
  for_each = {
    for sg in local.tenant_sg_allow_lists : "${sg.vpc_name}-${sg.sg_index}" => sg
  }

  # Naming convention for the security group.
  name        = "${local.cluster_name}-${var.tenant_sg_name}-${each.value.sg_index + 1}"
  description = "Security group for tenant ingress-gateway"
  # Retrieve the VPC ID from the vpc module using the vpc_name.
  vpc_id = var.vpc_id

  # Dynamically create ingress rules based on the allow_list for each security group.
  dynamic "ingress" {
    for_each = each.value.allow_list
    content {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
      description = "HTTPS ingress for Tenant ingress-gateway"
    }
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc[local.vpc_name_to_index[each.value.vpc_name]].vpc_cidr_block]
    description = "HTTP ingress from VPC"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc[local.vpc_name_to_index[each.value.vpc_name]].vpc_cidr_block]
    description = "HTTPS ingress from VPC"
  }

  ingress {
    from_port   = 15021
    to_port     = 15021
    protocol    = "tcp"
    cidr_blocks = [module.vpc[local.vpc_name_to_index[each.value.vpc_name]].vpc_cidr_block]
    description = "Istio ingress from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    description = "Egress All from VPC"
  }

  tags = merge(var.tags, {
    "Name" = "${local.cluster_name}-${var.tenant_sg_name}-${each.value.sg_index + 1}"
  })
}

resource "aws_security_group" "admin_sg" {
  # checkov:skip=CKV2_AWS_5: "false positive" -- this resource is only created for staging and prod based on the vpc_configs

  # Use a combination of vpc_name and sg_index to uniquely identify each security group in the for_each loop.
  for_each = {
    for sg in local.admin_sg_allow_lists : "${sg.vpc_name}-${sg.sg_index}" => sg
  }

  # Naming convention for the security group.
  name        = "${local.cluster_name}-${each.value.vpc_name}-${var.admin_sg_name}-${each.value.sg_index + 1}"
  description = "Security group for Keycloak with ingress rules"
  # Retrieve the VPC ID from the vpc module using the vpc_name.
  vpc_id = var.vpc_id

  # Dynamically create ingress rules based on the allow_list for each security group.
  dynamic "ingress" {
    for_each = each.value.allow_list
    content {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
      description = "HTTPS ingress for Keycloak"
    }
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc[local.vpc_name_to_index[each.value.vpc_name]].vpc_cidr_block]
    description = "HTTP ingress from VPC"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc[local.vpc_name_to_index[each.value.vpc_name]].vpc_cidr_block]
    description = "HTTPS ingress from VPC"
  }

  ingress {
    from_port   = 15021
    to_port     = 15021
    protocol    = "tcp"
    cidr_blocks = [module.vpc[local.vpc_name_to_index[each.value.vpc_name]].vpc_cidr_block]
    description = "Custom port ingress from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    description = "Egress All from VPC"
  }

  tags = merge(var.tags, {
    "Name" = "${local.cluster_name}${var.admin_sg_name}-${each.value.sg_index + 1}"
  })
}

resource "aws_security_group" "appstream_users_sgs" {
  # checkov:skip=CKV2_AWS_5: This resource is used in operations repo
  for_each = {
    for vpc in var.vpc_configs : vpc.vpc_name => vpc
    if vpc.default_vdi_vpc == true # Only create the security group for the default VDI VPC (which could be either 'VDI-RDTE-VPC' or 'VDI-Production-VPC' in the current configuration)
  }

  name        = "${var.tags.Environment}-${var.tags.Project}-${each.value.vpc_name}-appstream-users-sg"
  description = "Security group for regular appstream users"

  # Retrieve the VPC ID from the vpc module using the vpc_name.
  vpc_id = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [each.value.vpc_cidr]
  }

  egress {
    description = "EKS private subnets egress to AppStream fleet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.target_eks_private_subnets_cidrs
  }

  egress {
    description = "Outbound to MDE endpoints per onboarding docs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.mde_egress_cidrs
  }

  egress {
    description = "Keycloak endpoint"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.idp_public_ips
  }
}

output "keycloak_security_group_ids" {
  value = values(aws_security_group.keycloak_sg)[*].id
}

output "tenant_security_group_ids" {
  value = values(aws_security_group.tenant_sg)[*].id
}

output "admin_security_group_ids" {
  value = values(aws_security_group.admin_sg)[*].id
}
