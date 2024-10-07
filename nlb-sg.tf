locals {
  # Define sg_types and ports
  sg_types = ["tenant", "admin"]
  ports    = [80, 443]

  # Flatten sg_rules into a list of rules
  all_sg_rules = flatten(flatten([
    for sg_type, sg_data in var.sg_rules : [
      for port_str, cidr_blocks in sg_data.ports : [
        for cidr_block in cidr_blocks : {
          sg_type    = sg_type
          port       = tonumber(port_str)
          cidr_block = cidr_block
        }
      ]
    ]
  ]))

  # Generate all possible combinations of sg_type and port
  sg_type_port_combinations = flatten([
    for sg_type in local.sg_types : [
      for port in local.ports : "${sg_type}-${port}"
    ]
  ])

  # Existing combinations from provided rules
  existing_sg_type_ports = distinct([
    for rule in local.all_sg_rules : "${rule.sg_type}-${rule.port}"
  ])

  # Identify missing combinations
  missing_combinations = [
    for combo in local.sg_type_port_combinations :
    combo if !contains(local.existing_sg_type_ports, combo)
  ]

  # Create default rules for missing combinations
  default_sg_rules = [
    for combo_str in local.missing_combinations : {
      sg_type    = split(combo_str, "-")[0]
      port       = tonumber(split(combo_str, "-")[1])
      cidr_block = "0.0.0.0/0"
    }
  ]

  # Combine all rules
  sg_rules_combined = concat(local.all_sg_rules, local.default_sg_rules)

  # Separate rules by sg_type
  tenant_sg_rules = [
    for rule in local.sg_rules_combined : rule if rule.sg_type == "tenant"
  ]

  admin_sg_rules = [
    for rule in local.sg_rules_combined : rule if rule.sg_type == "admin"
  ]

  # Calculate the number of security groups needed for each type
  tenant_sg_counts = ceil(length(local.tenant_sg_rules) / 56)
  admin_sg_counts  = ceil(length(local.admin_sg_rules) / 56)

  # Chunk the rules into groups of up to 56
  tenant_sg_rules_chunks = [
    for i in range(local.tenant_sg_counts) : {
      sg_index = i
      rules    = slice(
        local.tenant_sg_rules,
        i * 56,
        min((i + 1) * 56, length(local.tenant_sg_rules))
      )
    }
  ]

  admin_sg_rules_chunks = [
    for i in range(local.admin_sg_counts) : {
      sg_index = i
      rules    = slice(
        local.admin_sg_rules,
        i * 56,
        min((i + 1) * 56, length(local.admin_sg_rules))
      )
    }
  ]
}

# Tenant Security Groups
resource "aws_security_group" "tenant_sg" {
  for_each = {
    for sg in local.tenant_sg_rules_chunks : sg.sg_index => sg
  }

  name        = "${var.tags.Environment}-tenant-elb-1-${each.value.sg_index + 1}"
  description = "Security group for tenant ingress-gateway"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = each.value.rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = [ingress.value.cidr_block]
      description = "Ingress rule"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Egress All from VPC"
  }

  tags = merge(var.tags, {
    "Name" = "${var.tags.Environment}-tenant-elb-1-${each.value.sg_index + 1}"
  })
}

# Admin Security Groups
resource "aws_security_group" "admin_sg" {
  for_each = {
    for sg in local.admin_sg_rules_chunks : sg.sg_index => sg
  }

  name        = "${var.tags.Environment}-admin-elb-1-${each.value.sg_index + 1}"
  description = "Security group for admin"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = each.value.rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = [ingress.value.cidr_block]
      description = "Ingress rule"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Egress All from VPC"
  }

  tags = merge(var.tags, {
    "Name" = "${var.tags.Environment}-admin-elb-1-${each.value.sg_index + 1}"
  })
}

# Outputs
output "tenant_security_group_ids" {
  value = [for sg in aws_security_group.tenant_sg : sg.id]
}

output "admin_security_group_ids" {
  value = [for sg in aws_security_group.admin_sg : sg.id]
}

# Additional Local Rules (if needed)
locals {
  node_security_group_additional_rules = {
    description              = "Allow ingress from NLB to Nodes"
    security_group_id        = module.aws_eks.node_security_group_id
    from_port                = 30000
    to_port                  = 32767
    protocol                 = "tcp"
    type                     = "ingress"
    source_security_group_id = aws_security_group.nlb_sg[0].id
  }
}

# NLB Security Group
resource "aws_security_group" "nlb_sg" {
  # checkov:skip=CKV2_AWS_5: This security group gets used when creating NLBs with uds-core.

  name        = "${var.tags.Project}-backend-nlb-sg"
  description = "Security group for NLB to Nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
