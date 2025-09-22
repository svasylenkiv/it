variable "account_id" {
  description = "AWS Account ID"
  type        = string
}
variable "env" { type = string }
variable "Environment" { type = string }
variable "OS" { type = string }
variable "region" { type = string }
variable "project_name" { type = string }
variable "tfstate_bucket" { type = string }
# Define input variable for Github token
variable "gh_token" { type = string }
variable "github_runner_label" { type = string }
variable "aspnetcore_environment" { type = string }
variable "newrelic_license_key" { type = string }
variable "new_relic_api_key" { type = string }

variable "common_email" {
  description = "DevOps email address for notifications"
}

variable "teams_alerts_email" {
  description = "Teams channel email address for notifications"
}

# platform-vpc-dev~stg
variable "vpc_id" { type = string }

variable "ami_config" {
  type = object({
    owner = string
    name  = string
  })
}
# LB subnets
variable "public_subnet_ids" { type = list(string) }

variable "lambda_subnet_ids" { type = list(string) }

variable "instance_config" {
  type = object({
    instance_type         = string
    root_volume_type      = string
    root_volume_size      = number
    encrypted             = bool
    delete_on_termination = bool
    subnet_id             = string
  })
}

variable "caseglide_instance_security_group_config" {
  type = list(object({
    name            = string
    type            = string
    protocol        = string
    from_port       = number
    to_port         = number
    cidr_blocks     = list(string)
    security_groups = list(string)
    description     = string
  }))
}

variable "common_tags" {
  type = object({
    Project     = string
    Environment = string
    Terraform   = string
  })
}

variable "managed_policies" {
  type = object({
    AmazonS3FullAccess                                                  = string
    AmazonEC2FullAccess                                                 = string
    AmazonSQSFullAccess                                                 = string
    AmazonSSMReadOnlyAccess                                             = string
    AmazonSSMManagedInstanceCore                                        = string
    caseglide-role-unified-project-CaseGlideApp_SSM_Parameter_ReadWrite = string
    caseglide-role-unified-project-CaseglidePushCloudwatchLogs          = string
    caseglide-role-unified-project-CaseGlideReadDomainJoinComputer      = string
  })
}

variable "caseglide_lb_security_group_config" {
  type = list(object({
    name            = string
    protocol        = string
    from_port       = number
    to_port         = number
    cidr_blocks     = list(string)
    security_groups = list(string)
    description     = string
  }))
}

#------------------------------------------------------------
# LB
#------------------------------------------------------------
variable "caseglide_webapp_lb_config" {
  type = object({
    internal                   = bool
    load_balancer_type         = string
    enable_deletion_protection = bool
    protocol                   = string
    port                       = string
  })
}

variable "front_end_80_config" {
  type = object({
    port              = string
    protocol          = string
    type              = string
    redirect_protocol = string
    redirect_port     = string
    status_code       = string
  })
}

variable "front_end_443_config" {
  type = object({
    port                  = string
    protocol              = string
    type                  = string
    ssl_policy            = string
    caseglide_certificate = string
  })
}

variable "target_group_webapp_config" {
  type = object({
    port        = number
    protocol    = string
    target_type = string
  })
}

variable "route53_cname_config" {
  type = object({
    zone_id = string
    name    = string
    type    = string
    ttl     = number
  })
}

variable "schedule" {
  description = "Schedule for the maintenance window"
  type        = string
}
### Variables for Elasticache
variable "old_project_name" { type = string }

variable "engine_version" {
  description = "The version of the cache engine"
  type        = string
}

variable "maintenance_window" {
  description = "The weekly time range for maintenance"
  type        = string
}

variable "node_type" {
  description = "The instance type of the cache nodes"
  type        = string
}

variable "num_cache_nodes" {
  description = "The number of cache nodes in the cluster"
  type        = number
}

variable "parameter_group_name" {
  description = "The parameter group associated with the cache cluster"
  type        = string
}

variable "max_item_size" {
  description = "The parameter group associated with the cache cluster"
  type        = string
}

variable "security_group_ids" {
  description = "The security group IDs for the cache cluster"
  type        = list(string)
}

variable "lambda_security_group_ids" {
  description = "The security group IDs for the lambda"
  type        = list(string)
}

variable "redis_security_group_ids" {
  description = "The security group IDs for the cache cluster"
  type        = list(string)
}

variable "tags" {
  description = "Tags for the ElastiCache cluster"
  type        = map(string)
}

variable "preferred_availability_zones" {
  description = "List of preferred availability zones for the cluster"
  type        = list(string)
}

variable "approved_after_days" {
  description = "Number of days after which approved patches are applied"
  type        = number
}

variable "kms_key_id" {
  type        = string
  description = "UUID or ARN of the KMS key"
}

variable "dlq_arn" {
  type        = string
  description = "ARN of the dead-letter queue"
}
