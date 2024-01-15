output "arn" {
  value       = aws_sns_topic.this.arn
  description = "The ARN of the created SNS topic."
}

output "subscription_arns" {
  value       = aws_sns_topic_subscription.this[*].arn
  description = "List of ARNs for the created SNS topic subscriptions."
}
