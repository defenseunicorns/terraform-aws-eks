locals {
  availability_zone_name = slice(data.aws_availability_zones.available.names, 0, 3)
  azs                    = slice(data.aws_availability_zones.available.names, 0, 3)

  cluster_name = coalesce(var.cluster_name, var.name)
}
