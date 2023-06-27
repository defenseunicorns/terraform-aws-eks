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
 

  auth_eks_role_policy = var.eks_use_mfa ? 
<<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
              "AWS": ${length(local.admin_arns) == 0 ? "[]" : jsonencode(local.admin_arns)}
            },
            "Effect": "Allow",
            "Condition": {"Bool": {"aws:MultiFactorAuthPresent": "true"}}
        }
    ]
}
EOF 
: 
<<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
              "AWS": ${length(local.admin_arns) == 0 ? "[]" : jsonencode(local.admin_arns)}
            },
            "Effect": "Allow"
        }
    ]
}
EOF

}


