plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

config {
  # praise to chatgpt for making this abomination
  variables = [
    "cluster_addons={\"vpc-cni\"={\"most_recent\"=true, \"before_compute\"=true, \"configuration_values\"=\"{\\\"env\\\": {\\\"AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG\\\": \\\"true\\\", \\\"ENABLE_PREFIX_DELEGATION\\\": \\\"true\\\", \\\"ENI_CONFIG_LABEL_DEF\\\": \\\"topology.kubernetes.io/zone\\\", \\\"WARM_PREFIX_TARGET\\\": \\\"1\\\", \\\"ANNOTATE_POD_IP\\\": \\\"true\\\", \\\"POD_SECURITY_GROUP_ENFORCING_MODE\\\": \\\"standard\\\"}, \\\"enableNetworkPolicy\\\": \\\"true\\\"}\"}, \"coredns\"={\"most_recent\"=true, \"timeouts\"={\"create\"=\"2m\", \"delete\"=\"2m\"}}, \"kube-proxy\"={\"most_recent\"=true}, \"aws-ebs-csi-driver\"={\"most_recent\"=true, \"configuration_values\"=\"{\\\"defaultStorageClass\\\": {\\\"enabled\\\": true}}\", \"timeouts\"={\"create\"=\"2m\", \"delete\"=\"2m\"}}, \"aws-efs-csi-driver\"={\"most_recent\"=true, \"timeouts\"={\"create\"=\"2m\", \"delete\"=\"2m\"}}}"
  ]
}

#plugin "aws" {
#  enabled = true
#  version = "0.23.0"
#  source  = "github.com/terraform-linters/tflint-ruleset-aws"
#}
