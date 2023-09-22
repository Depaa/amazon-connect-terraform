resource "aws_sns_topic" "this" {
  name = var.topic_name
}

resource "aws_sns_topic_subscription" "this" {
  count = length(var.subscription_endpoints)

  topic_arn = aws_sns_topic.this.arn
  endpoint  = var.subscription_endpoints[count.index]
  protocol  = "email"
}
