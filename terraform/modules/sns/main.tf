# SNS Topic
resource "aws_sns_topic" "health_check_service" {
  name = "${var.project_name}-health-status-topic"
}

# SNS Subscription
resource "aws_sns_topic_subscription" "health_updates_email_target" {
  topic_arn = aws_sns_topic.health_check_service.arn
  protocol  = "email"
  endpoint  = var.subscription_email
}
