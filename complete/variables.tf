variable "name_prefix" {
  description = "The prefix to use when naming all resources"
  type        = string
  validation {
    condition     = length(var.name_prefix) <= 20
    error_message = "The name prefix cannot be more than 20 characters"
  }
  default = "ci"
}

variable "region" {
  description = "The AWS region to deploy into"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "iam_role_permissions_boundary" {
  description = "ARN of a permissions boundary policy to use when creating IAM roles"
  type        = string
  default     = null
}

variable "ip_offsets_per_subnet" {
  description = "List of offsets for IP reservations in each subnet."
  type        = list(list(number))
  default     = [[5, 6], [5, 6], [5]] # Default to fifth and sixth IPs for each subnet.
}
