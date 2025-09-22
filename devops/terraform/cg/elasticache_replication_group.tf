resource "aws_elasticache_replication_group" "redis" {
  at_rest_encryption_enabled = "true"
  auto_minor_version_upgrade = "true"
  automatic_failover_enabled = "true"
  cluster_mode               = "disabled"
  data_tiering_enabled       = "false"
  description                = "redis for ${var.env}"
  engine                     = "redis"
  engine_version             = "7.1"
  ip_discovery               = "ipv4"

  log_delivery_configuration {
    destination      = "/aws/redis/${var.env}"
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = "/aws/redis/${var.env}-engine"
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }

  maintenance_window       = "sun:05:00-sun:08:00"
  multi_az_enabled         = "true"
  network_type             = "ipv4"
  node_type                = var.node_type
  num_node_groups          = "1"
  parameter_group_name     = "default.redis7"
  port                     = "6379"
  replicas_per_node_group  = "1"
  replication_group_id     = var.env
  security_group_ids       = var.redis_security_group_ids
  snapshot_retention_limit = "1"
  snapshot_window          = "02:30-04:30"
  subnet_group_name        = "platform-vpc-${var.env}"

  tags = merge(var.tags, {
    Environment = var.tags["Environment"]
    Terraform   = var.tags["Terraform"]
  })

  transit_encryption_enabled = "true"
  transit_encryption_mode    = "required"
}
