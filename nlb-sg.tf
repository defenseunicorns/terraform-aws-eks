locals {
  # Flatten sg_rules into a list of rules with sg_type derived from elb_id
  all_sg_rules = flatten(flatten([
    for elb_id, elb_data in var.sg_rules : [
      for port_str, cidr_blocks in elb_data.ports : [
        for cidr_block in cidr_blocks : {
          elb_id     = elb_id
          port       = tonumber(port_str)
          cidr_block = cidr_block
          sg_type    = contains(lower(elb_id), "admin") ? "admin" : "tenant"
        }
      ]
    ]
  ]))

  # Define sg_types and ports
  sg_types = ["tenant", "admin"]
  ports    = [80, 443]

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
      elb_id     = null
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
      description = ingress.value.elb_id != null ? "Ingress rule for ELB ${ingress.value.elb_id}" : "Default ingress rule"
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
      description = ingress.value.elb_id != null ? "Ingress rule for ELB ${ingress.value.elb_id}" : "Default ingress rule"
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

output "tenant_security_group_ids" {
  value = [for sg in aws_security_group.tenant_sg : sg.id]
}

output "admin_security_group_ids" {
  value = [for sg in aws_security_group.admin_sg : sg.id]
}
