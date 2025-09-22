resource "aws_sns_topic" "alerts_sns_topic" {
  name         = "${var.project_name}-${var.env}-sns-topic"
  display_name = "${var.project_name} ${var.env} SNS Topic"
}

resource "aws_sns_topic_subscription" "email_subscription_1" {
  topic_arn = aws_sns_topic.alerts_sns_topic.arn
  protocol  = "email"
  endpoint  = var.common_email
}

resource "aws_sns_topic_subscription" "email_subscription_2" {
  topic_arn = aws_sns_topic.alerts_sns_topic.arn
  protocol  = "email"
  endpoint  = var.teams_alerts_email
}
