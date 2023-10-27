
# examples/complete


# examples/complete

Example that uses the module with many of its configurations. Used in CI E2E tests.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.62.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [random_id.default](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of a permissions boundary policy to use when creating IAM roles | `string` | `null` | no |
| <a name="input_ip_offsets_per_subnet"></a> [ip\_offsets\_per\_subnet](#input\_ip\_offsets\_per\_subnet) | List of offsets for IP reservations in each subnet. | `list(list(number))` | <pre>[<br>  [<br>    5,<br>    6<br>  ],<br>  [<br>    5,<br>    6<br>  ],<br>  [<br>    5<br>  ]<br>]</pre> | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The prefix to use when naming all resources | `string` | `"ci"` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy into | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_reserved_ips_per_subnet"></a> [reserved\_ips\_per\_subnet](#output\_reserved\_ips\_per\_subnet) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
