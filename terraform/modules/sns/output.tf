output "sns_topic_arn" {
  value = aws_sns_topic.health_check_service.arn
}
