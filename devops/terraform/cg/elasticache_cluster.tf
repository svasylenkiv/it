resource "aws_elasticache_parameter_group" "memcached_parameters" {
  name        = "custom-01-memcached-1-6-6-${var.env}"
  family      = "memcached1.6"
  description = "Parameter group for memcached 1.6 with max_item_size of 25MB"

  parameter {
    name  = "max_item_size"
    value = var.max_item_size
  }
}

resource "aws_elasticache_cluster" "cluster" {
  auto_minor_version_upgrade   = true
  az_mode                      = "cross-az"
  cluster_id                   = "${var.old_project_name}-memcache-${var.env}"
  engine                       = "memcached"
  engine_version               = var.engine_version
  ip_discovery                 = "ipv4"
  maintenance_window           = var.maintenance_window
  network_type                 = "ipv4"
  node_type                    = var.node_type
  num_cache_nodes              = var.num_cache_nodes
  parameter_group_name         = aws_elasticache_parameter_group.memcached_parameters.name
  port                         = 11211
  security_group_ids           = var.security_group_ids
  snapshot_retention_limit     = 0
  subnet_group_name            = "platform-vpc-${var.env}"
  preferred_availability_zones = var.preferred_availability_zones

  tags = merge(var.tags, {
    Environment = var.tags["Environment"]
    Terraform   = var.tags["Terraform"]
  })

  transit_encryption_enabled = false
}
