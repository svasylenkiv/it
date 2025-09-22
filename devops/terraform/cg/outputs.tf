output "latest_amazon_linux_ami_id" {
  value = data.aws_ami.latest_amazon_linux_ami.id
}

output "sns_topic_arn" {
  value       = aws_sns_topic.alerts_sns_topic.arn
  description = "The ARN of the Alerts SNS topic"
}

output "target_group_arns" {
  value = aws_lb_target_group.target_group_webapp.arn
}