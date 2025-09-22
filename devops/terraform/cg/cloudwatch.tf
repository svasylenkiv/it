resource "aws_cloudwatch_metric_alarm" "disk_space_used_more_75" {
  alarm_name          = "${var.project_name}-${var.env}-linux-disk_space-used-more-75%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "This metric monitors disk space usage on instance ${aws_instance.cg-unified-project-instance.id}."
  actions_enabled     = true

  alarm_actions = [aws_sns_topic.alerts_sns_topic.arn]

  ok_actions = [aws_sns_topic.alerts_sns_topic.arn]

  dimensions = {
    path         = "/"
    InstanceId   = aws_instance.cg-unified-project-instance.id
    ImageId      = aws_instance.cg-unified-project-instance.ami
    InstanceType = aws_instance.cg-unified-project-instance.instance_type
    device       = "nvme0n1p1"
    fstype       = "xfs"
  }

  treat_missing_data = "notBreaching"

  tags = merge(var.common_tags, { Name = "${var.project_name}-${var.common_tags["Environment"]}" })

}

resource "aws_cloudwatch_metric_alarm" "disk_space_used_more_90" {
  alarm_name          = "${var.project_name}-${var.env}-linux-disk_space-used-more-90%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "This metric monitors disk space usage on instance ${aws_instance.cg-unified-project-instance.id}."
  actions_enabled     = true

  alarm_actions = [aws_sns_topic.alerts_sns_topic.arn]

  ok_actions = [aws_sns_topic.alerts_sns_topic.arn]


  dimensions = {
    path         = "/"
    InstanceId   = aws_instance.cg-unified-project-instance.id
    ImageId      = aws_instance.cg-unified-project-instance.ami
    InstanceType = aws_instance.cg-unified-project-instance.instance_type
    device       = "nvme0n1p1"
    fstype       = "xfs"
  }

  treat_missing_data = "notBreaching"

  tags = merge(var.common_tags, { Name = "${var.project_name}-${var.common_tags["Environment"]}" })

}

resource "aws_cloudwatch_metric_alarm" "memory_used_more_80" {
  alarm_name          = "${var.project_name}-${var.env}-linux-memory-used-more-80%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  actions_enabled     = true

  alarm_actions = [aws_sns_topic.alerts_sns_topic.arn]

  ok_actions = [aws_sns_topic.alerts_sns_topic.arn]


  dimensions = {
    InstanceId   = aws_instance.cg-unified-project-instance.id
    ImageId      = aws_instance.cg-unified-project-instance.ami
    InstanceType = aws_instance.cg-unified-project-instance.instance_type
  }

  treat_missing_data = "notBreaching"

  tags = merge(var.common_tags, { Name = "${var.project_name}-${var.common_tags["Environment"]}" })

}

resource "aws_cloudwatch_metric_alarm" "site_availability" {
  alarm_name          = "site-availability-unified-${var.env}-1"
  alarm_description   = "Synthetics alarm metric: SuccessPercent LessThanThreshold 90. Site: vnext.${var.env}.caseglide-aws.com - is down!"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 5
  threshold           = 90.0
  actions_enabled     = true
  datapoints_to_alarm = 5
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts_sns_topic.arn]
  ok_actions          = [aws_sns_topic.alerts_sns_topic.arn]

  tags = merge(var.common_tags, { Name = "${var.project_name}-${var.common_tags["Environment"]}" })

  metric_query {
    id          = "m1"
    return_data = false

    metric {
      metric_name = "SuccessPercent"
      namespace   = "CloudWatchSynthetics"
      period      = 360
      stat        = "Average"
      dimensions = {
        CanaryName = "unified-${var.env}"
      }
    }
  }

  metric_query {
    id          = "e1"
    expression  = "IF((HOUR(m1) < 0 OR HOUR(m1) >= 10), m1, 95)"
    label       = "Expression1"
    period      = 0
    return_data = true
  }
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space_less_10Gb" {
  alarm_name          = "caseglide-db-${var.env}_free-storage-space-less-10Gb"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 5
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 10737418240.0
  actions_enabled     = true
  datapoints_to_alarm = 5
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = "caseglide-db-${var.env}"
  }

  alarm_actions = [aws_sns_topic.alerts_sns_topic.arn]

  ok_actions = [aws_sns_topic.alerts_sns_topic.arn]

  tags = merge(var.common_tags, { Name = "${var.project_name}-${var.common_tags["Environment"]}" })

}

resource "aws_cloudwatch_metric_alarm" "free_storage_space_less_25Gb" {
  alarm_name          = "caseglide-db-${var.env}_free-storage-space-less-25Gb"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 5
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 10737418240.0
  actions_enabled     = true
  datapoints_to_alarm = 5
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = "caseglide-db-${var.env}"
  }

  alarm_actions = [aws_sns_topic.alerts_sns_topic.arn]

  ok_actions = [aws_sns_topic.alerts_sns_topic.arn]

  tags = merge(var.common_tags, { Name = "${var.project_name}-${var.common_tags["Environment"]}" })

}

resource "aws_cloudwatch_metric_alarm" "dbload_cpu" {
  alarm_name          = "${var.env}_dbload_cpu"
  alarm_description   = "Monitors the VCPU connections to ${var.env} DB"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "DBLoadCPU"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 7.0
  actions_enabled     = true
  datapoints_to_alarm = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = "caseglide-db-${var.env}"
  }

  alarm_actions = [aws_sns_topic.alerts_sns_topic.arn]

  ok_actions = [aws_sns_topic.alerts_sns_topic.arn]

  tags = merge(var.common_tags, { Name = "${var.project_name}-${var.common_tags["Environment"]}" })
}
