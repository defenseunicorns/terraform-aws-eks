# AWS EKS Module

This repository contains Terraform configuration files that create an Amazon Elastic Kubernetes Service (EKS) cluster. This module sets various paremeters for this cluster including the cluster name, version, VPC information, security group rules, and user and role mappings. Additionally, it sets up self-managed node groups for the EKS cluster.

## Examples

To view examples for how you can leverage this EKS Module, please see the [examples](https://github.com/defenseunicorns/terraform-aws-eks/tree/main/examples) directory.

## Bastion

You can use the bastion instance to connect to the EKS cluster when the cluster's endpoint is not publicly accessible. We use sshuttle combined with SSM to forward all traffic through the bastion instance to the EKS cluster. This allows you to use `kubectl` to interact with the EKS cluster from your local machine.

Use of `sshuttle` with password:

1. Set Bastion ID `export BASTION_INSTANCE_ID=$(terraform output -raw bastion_instance_id)`
1. Connect to bastion: `sshuttle --dns -vr ec2-user@$BASTION_INSTANCE_ID 10.200.0.0/16`

Use of `sshuttle` with private key:

1. Set Bastion ID `export BASTION_INSTANCE_ID=$(terraform output -raw bastion_instance_id)`
1. Dump key: `terraform output -raw bastion_instance_private_key > priv.key; chmod 600 priv.key`
1. Connect to bastion: `sshuttle --dns -vr ec2-user@$BASTION_INSTANCE_ID 10.200.0.0/16 --ssh-cmd 'ssh -i priv.key'`
1. Delete key afterwards: `rm priv.key`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.34 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.7 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.20 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.34 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.20 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_eks"></a> [aws\_eks](#module\_aws\_eks) | git::https://github.com/terraform-aws-modules/terraform-aws-eks.git | v20.8.4 |
| <a name="module_ebs_csi_driver_irsa"></a> [ebs\_csi\_driver\_irsa](#module\_ebs\_csi\_driver\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.20 |
| <a name="module_efs"></a> [efs](#module\_efs) | terraform-aws-modules/efs/aws | ~> 1.0 |
| <a name="module_efs_csi_driver_irsa"></a> [efs\_csi\_driver\_irsa](#module\_efs\_csi\_driver\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.20 |
| <a name="module_eks_blueprints_kubernetes_addons"></a> [eks\_blueprints\_kubernetes\_addons](#module\_eks\_blueprints\_kubernetes\_addons) | git::https://github.com/aws-ia/terraform-aws-eks-blueprints-addons.git | v1.16.1 |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.file_system_id_for_efs_storage_class](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.helm_input_values](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [kubernetes_annotations.gp2](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/annotations) | resource |
| [kubernetes_storage_class_v1.efs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [kubernetes_storage_class_v1.gp3](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [random_id.efs_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_entries"></a> [access\_entries](#input\_access\_entries) | Map of access entries to add to the cluster | `any` | `{}` | no |
| <a name="input_authentication_mode"></a> [authentication\_mode](#input\_authentication\_mode) | The authentication mode for the cluster. Valid values are `CONFIG_MAP`, `API` or `API_AND_CONFIG_MAP` | `string` | `"API_AND_CONFIG_MAP"` | no |
| <a name="input_aws_admin_usernames"></a> [aws\_admin\_usernames](#input\_aws\_admin\_usernames) | A list of one or more AWS usernames with authorized access to KMS and EKS resources, will automatically add the user running the terraform as an admin | `list(string)` | `[]` | no |
| <a name="input_aws_cloudwatch_metrics"></a> [aws\_cloudwatch\_metrics](#input\_aws\_cloudwatch\_metrics) | AWS Cloudwatch Metrics config for aws-ia/eks-blueprints-addon/aws | `any` | `{}` | no |
| <a name="input_aws_fsx_csi_driver"></a> [aws\_fsx\_csi\_driver](#input\_aws\_fsx\_csi\_driver) | FSX CSI Driver config for aws-ia/eks-blueprints-addon/aws | `any` | `{}` | no |
| <a name="input_aws_load_balancer_controller"></a> [aws\_load\_balancer\_controller](#input\_aws\_load\_balancer\_controller) | AWS Loadbalancer Controller config for aws-ia/eks-blueprints-addon/aws | `any` | `{}` | no |
| <a name="input_aws_node_termination_handler"></a> [aws\_node\_termination\_handler](#input\_aws\_node\_termination\_handler) | AWS Node Termination Handler config for aws-ia/eks-blueprints-addon/aws | `any` | `{}` | no |
| <a name="input_aws_privateca_issuer"></a> [aws\_privateca\_issuer](#input\_aws\_privateca\_issuer) | AWS Private CA Issuer config for aws-ia/eks-blueprints-addon/aws | `any` | `{}` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `""` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | List of names of availability zones to use for subnet configs | `list(string)` | `[]` | no |
| <a name="input_blueprints_addons_prefixes"></a> [blueprints\_addons\_prefixes](#input\_blueprints\_addons\_prefixes) | Prefixes for the eks blueprints addons, used to parse addon gitops\_metadata output and create objects with | `list(string)` | <pre>[<br>  "cert_manager",<br>  "cluster_autoscaler",<br>  "aws_cloudwatch_metrics",<br>  "aws_efs_csi_driver",<br>  "aws_fsx_csi_driver",<br>  "aws_privateca_issuer",<br>  "external_dns_route53",<br>  "external_secrets",<br>  "aws_load_balancer_controller",<br>  "aws_for_fluentbit",<br>  "aws_node_termination_handler",<br>  "karpenter",<br>  "velero",<br>  "aws_gateway_api_controller",<br>  "fargate_fluentbit_log"<br>]</pre> | no |
| <a name="input_bottlerocket_shadow"></a> [bottlerocket\_shadow](#input\_bottlerocket\_shadow) | Bottlerocket Shadow config for aws-ia/eks-blueprints-addon/aws | `any` | `{}` | no |
| <a name="input_bottlerocket_update_operator"></a> [bottlerocket\_update\_operator](#input\_bottlerocket\_update\_operator) | Bottlerocket Update Operator config for aws-ia/eks-blueprints-addon/aws | `any` | `{}` | no |
| <a name="input_cert_manager"></a> [cert\_manager](#input\_cert\_manager) | Cert Manager config for aws-ia/eks-blueprints-addon/aws | `any` | `{}` | no |
| <a name="input_cert_manager_route53_hosted_zone_arns"></a> [cert\_manager\_route53\_hosted\_zone\_arns](#input\_cert\_manager\_route53\_hosted\_zone\_arns) | List of Route53 Hosted Zone ARNs that are used by cert-manager to create DNS records | `list(string)` | `[]` | no |
| <a name="input_cluster_addons"></a> [cluster\_addons](#input\_cluster\_addons) | Nested of eks native add-ons and their associated parameters.<br>See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon for supported values.<br>See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/complete/main.tf#L44-L60 for upstream example.<br><br>to see available eks marketplace addons available for your cluster's version run:<br>aws eks describe-addon-versions --kubernetes-version $k8s\_cluster\_version --query 'addons[].{MarketplaceProductUrl: marketplaceInformation.productUrl, Name: addonName, Owner: owner Publisher: publisher, Type: type}' --output table | `any` | `{}` | no |
| <a name="input_cluster_autoscaler"></a> [cluster\_autoscaler](#input\_cluster\_autoscaler) | Cluster Autoscaler config for aws-ia/eks-blueprints-addon/aws | `any` | <pre>{<br>  "set": [<br>    {<br>      "name": "extraArgs.expander",<br>      "value": "priority"<br>    },<br>    {<br>      "name": "expanderPriorities",<br>      "value": "100:\n  - .*-spot-2vcpu-8mem.*\n90:\n  - .*-spot-4vcpu-16mem.*\n10:\n  - .*\n"<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Enable private access to the cluster endpoint | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Enable public access to the cluster endpoint | `bool` | `false` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of cluster | `string` | `""` | no |
| <a name="input_cluster_security_group_additional_rules"></a> [cluster\_security\_group\_additional\_rules](#input\_cluster\_security\_group\_additional\_rules) | List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source | `any` | `{}` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes version to use for EKS cluster | `string` | `"1.29"` | no |
| <a name="input_control_plane_subnet_ids"></a> [control\_plane\_subnet\_ids](#input\_control\_plane\_subnet\_ids) | Subnet IDs for control plane | `list(string)` | `[]` | no |
| <a name="input_create_eni_configs"></a> [create\_eni\_configs](#input\_create\_eni\_configs) | Merge ENI configs for VPC CNI into cluster\_addons configuration | `bool` | `true` | no |
| <a name="input_create_kubernetes_resources"></a> [create\_kubernetes\_resources](#input\_create\_kubernetes\_resources) | Create Kubernetes resource with Helm or Kubernetes provider | `bool` | `true` | no |
| <a name="input_create_ssm_parameters"></a> [create\_ssm\_parameters](#input\_create\_ssm\_parameters) | Create SSM parameters for values from eks blueprints addons outputs | `bool` | `true` | no |
| <a name="input_dataplane_wait_duration"></a> [dataplane\_wait\_duration](#input\_dataplane\_wait\_duration) | Duration to wait after the EKS cluster has become active before creating the dataplane components (EKS managed nodegroup(s), self-managed nodegroup(s), Fargate profile(s)) | `string` | `"4m"` | no |
| <a name="input_ebs_storageclass_reclaim_policy"></a> [ebs\_storageclass\_reclaim\_policy](#input\_ebs\_storageclass\_reclaim\_policy) | Reclaim policy for gp3 storage class, valid options are Delete and Retain | `string` | `"Delete"` | no |
| <a name="input_efs_storageclass_reclaim_policy"></a> [efs\_storageclass\_reclaim\_policy](#input\_efs\_storageclass\_reclaim\_policy) | Reclaim policy for EFS storage class, valid options are Delete and Retain | `string` | `"Delete"` | no |
| <a name="input_efs_vpc_cidr_blocks"></a> [efs\_vpc\_cidr\_blocks](#input\_efs\_vpc\_cidr\_blocks) | CIDR blocks to allow access to EFS | `list(string)` | `[]` | no |
| <a name="input_eks_managed_node_group_defaults"></a> [eks\_managed\_node\_group\_defaults](#input\_eks\_managed\_node\_group\_defaults) | Map of EKS-managed node group default configurations | `any` | `{}` | no |
| <a name="input_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#input\_eks\_managed\_node\_groups) | Managed node groups configuration | `any` | `{}` | no |
| <a name="input_enable_amazon_eks_aws_ebs_csi_driver"></a> [enable\_amazon\_eks\_aws\_ebs\_csi\_driver](#input\_enable\_amazon\_eks\_aws\_ebs\_csi\_driver) | Enable EKS Managed AWS EBS CSI Driver add-on | `bool` | `false` | no |
| <a name="input_enable_amazon_eks_aws_efs_csi_driver"></a> [enable\_amazon\_eks\_aws\_efs\_csi\_driver](#input\_enable\_amazon\_eks\_aws\_efs\_csi\_driver) | Enable EFS CSI Driver add-on | `bool` | `false` | no |
| <a name="input_enable_aws_cloudwatch_metrics"></a> [enable\_aws\_cloudwatch\_metrics](#input\_enable\_aws\_cloudwatch\_metrics) | Enable AWS Cloudwatch Metrics add-on | `bool` | `false` | no |
| <a name="input_enable_aws_fsx_csi_driver"></a> [enable\_aws\_fsx\_csi\_driver](#input\_enable\_aws\_fsx\_csi\_driver) | Enable FSX CSI Driver add-on | `bool` | `false` | no |
| <a name="input_enable_aws_load_balancer_controller"></a> [enable\_aws\_load\_balancer\_controller](#input\_enable\_aws\_load\_balancer\_controller) | Enable AWS Loadbalancer Controller add-on | `bool` | `false` | no |
| <a name="input_enable_aws_node_termination_handler"></a> [enable\_aws\_node\_termination\_handler](#input\_enable\_aws\_node\_termination\_handler) | Enable AWS Node Termination Handler add-on | `bool` | `false` | no |
| <a name="input_enable_aws_privateca_issuer"></a> [enable\_aws\_privateca\_issuer](#input\_enable\_aws\_privateca\_issuer) | Enable AWS Private CA Issuer add-on | `bool` | `false` | no |
| <a name="input_enable_bottlerocket_update_operator"></a> [enable\_bottlerocket\_update\_operator](#input\_enable\_bottlerocket\_update\_operator) | Enable Bottlerocket and Bottlerocket Update Operator add-on | `bool` | `false` | no |
| <a name="input_enable_cert_manager"></a> [enable\_cert\_manager](#input\_enable\_cert\_manager) | Enable Cert Manager add-on | `bool` | `false` | no |
| <a name="input_enable_cluster_autoscaler"></a> [enable\_cluster\_autoscaler](#input\_enable\_cluster\_autoscaler) | Enable Cluster autoscaler add-on | `bool` | `false` | no |
| <a name="input_enable_cluster_creator_admin_permissions"></a> [enable\_cluster\_creator\_admin\_permissions](#input\_enable\_cluster\_creator\_admin\_permissions) | Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via access entry | `bool` | `true` | no |
| <a name="input_enable_external_dns"></a> [enable\_external\_dns](#input\_enable\_external\_dns) | Enable External DNS add-on | `bool` | `false` | no |
| <a name="input_enable_external_secrets"></a> [enable\_external\_secrets](#input\_enable\_external\_secrets) | Enable External Secrets add-on | `bool` | `false` | no |
| <a name="input_enable_gp3_default_storage_class"></a> [enable\_gp3\_default\_storage\_class](#input\_enable\_gp3\_default\_storage\_class) | Enable gp3 as default storage class | `bool` | `false` | no |
| <a name="input_enable_karpenter"></a> [enable\_karpenter](#input\_enable\_karpenter) | Enable Karpenter add-on | `bool` | `false` | no |
| <a name="input_enable_metrics_server"></a> [enable\_metrics\_server](#input\_enable\_metrics\_server) | Enable metrics server add-on | `bool` | `false` | no |
| <a name="input_enable_secrets_store_csi_driver"></a> [enable\_secrets\_store\_csi\_driver](#input\_enable\_secrets\_store\_csi\_driver) | Enable k8s Secret Store CSI Driver add-on | `bool` | `false` | no |
| <a name="input_external_dns"></a> [external\_dns](#input\_external\_dns) | External DNS config for aws-ia/eks-blueprints-addon/aws | `any` | `{}` | no |
| <a name="input_external_secrets"></a> [external\_secrets](#input\_external\_secrets) | External Secrets config for aws-ia/eks-blueprints-addon/aws | `any` | `{}` | no |
| <a name="input_external_secrets_kms_key_arns"></a> [external\_secrets\_kms\_key\_arns](#input\_external\_secrets\_kms\_key\_arns) | List of KMS Key ARNs that are used by Secrets Manager that contain secrets to mount using External Secrets | `list(string)` | `[]` | no |
| <a name="input_external_secrets_secrets_manager_arns"></a> [external\_secrets\_secrets\_manager\_arns](#input\_external\_secrets\_secrets\_manager\_arns) | List of Secrets Manager ARNs that contain secrets to mount using External Secrets | `list(string)` | `[]` | no |
| <a name="input_external_secrets_ssm_parameter_arns"></a> [external\_secrets\_ssm\_parameter\_arns](#input\_external\_secrets\_ssm\_parameter\_arns) | List of Systems Manager Parameter ARNs that contain secrets to mount using External Secrets | `list(string)` | `[]` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_karpenter"></a> [karpenter](#input\_karpenter) | Karpenter config for aws-ia/eks-blueprints-addon/aws | `any` | `{}` | no |
| <a name="input_kms_key_administrators"></a> [kms\_key\_administrators](#input\_kms\_key\_administrators) | List of ARNs of additional administrator users to add to KMS key policy | `list(string)` | `[]` | no |
| <a name="input_metrics_server"></a> [metrics\_server](#input\_metrics\_server) | Metrics Server config for aws-ia/eks-blueprints-addon/aws | `any` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `""` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnet IDs | `list(string)` | `[]` | no |
| <a name="input_secrets_store_csi_driver"></a> [secrets\_store\_csi\_driver](#input\_secrets\_store\_csi\_driver) | k8s Secret Store CSI Driver config for aws-ia/eks-blueprints-addon/aws | `any` | `{}` | no |
| <a name="input_self_managed_node_group_defaults"></a> [self\_managed\_node\_group\_defaults](#input\_self\_managed\_node\_group\_defaults) | Map of self-managed node group default configurations | `any` | `{}` | no |
| <a name="input_self_managed_node_groups"></a> [self\_managed\_node\_groups](#input\_self\_managed\_node\_groups) | Self-managed node groups configuration | `any` | `{}` | no |
| <a name="input_ssm_parameter_kms_key_arn"></a> [ssm\_parameter\_kms\_key\_arn](#input\_ssm\_parameter\_kms\_key\_arn) | KMS key arn for use with SSM parameter encryption/decryption | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_cni_custom_subnet"></a> [vpc\_cni\_custom\_subnet](#input\_vpc\_cni\_custom\_subnet) | Subnet to put pod ENIs in | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | EKS cluster certificate authority data |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | EKS cluster endpoint |
| <a name="output_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#output\_cluster\_iam\_role\_arn) | EKS cluster IAM role ARN |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the EKS cluster |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | EKS cluster security group ID |
| <a name="output_cluster_status"></a> [cluster\_status](#output\_cluster\_status) | status of the EKS cluster |
| <a name="output_efs_storageclass_name"></a> [efs\_storageclass\_name](#output\_efs\_storageclass\_name) | The name of the EFS storageclass that was created (if var.enable\_amazon\_eks\_aws\_efs\_csi\_driver was set to true) |
| <a name="output_eks_addons_gitops_metadata"></a> [eks\_addons\_gitops\_metadata](#output\_eks\_addons\_gitops\_metadata) | ############################################################################### EKS Addons metadata ############################################################################### see https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/main/outputs.tf#L167-L276 |
| <a name="output_managed_nodegroups"></a> [managed\_nodegroups](#output\_managed\_nodegroups) | EKS managed node groups |
| <a name="output_oidc_provider"></a> [oidc\_provider](#output\_oidc\_provider) | The OpenID Connect identity provider (issuer URL without leading `https://`) |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | EKS OIDC provider ARN |
| <a name="output_region"></a> [region](#output\_region) | AWS region |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
