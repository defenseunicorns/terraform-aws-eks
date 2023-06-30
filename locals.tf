
locals {
  availability_zone_name = slice(data.aws_availability_zones.available.names, 0, 3)
  azs                    = slice(data.aws_availability_zones.available.names, 0, 3)

  # var.cluster_name is for Terratest

  cluster_name = coalesce(var.cluster_name, var.name)
  admin_arns = distinct(concat(
    [for admin_user in var.aws_admin_usernames : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:user/${admin_user}"],
    [data.aws_caller_identity.current.arn]
  ))
  aws_auth_users = [for admin_user in var.aws_admin_usernames : {
    userarn  = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:user/${admin_user}"
    username = admin_user
    groups   = ["system:masters"]
  }]

  eks_admin_arns = length(local.admin_arns) == 0 ? "[]" : jsonencode(local.admin_arns)

  # Used to resolve non-MFA policy. See https://docs.fugue.co/FG_R00255.html
  auth_eks_role_policy = var.eks_use_mfa ? jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          AWS = local.eks_admin_arns
        },
        Effect = "Allow"
        Sid = ""
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      }
    ]
    }) : jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          AWS = local.eks_admin_arns
        },
        Effect = "Allow"
        Sid = ""
      }
    ]
  })
}