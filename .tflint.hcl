plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

config {
  variables = [
    "cluster_addons={\"vpc-cni\"={\"most_recent\"=true, \"before_compute\"=true}}"
  ]
}

#plugin "aws" {
#  enabled = true
#  version = "0.23.0"
#  source  = "github.com/terraform-linters/tflint-ruleset-aws"
#}
