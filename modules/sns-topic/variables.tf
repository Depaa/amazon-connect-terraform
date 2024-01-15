variable "topic_name" {
  type        = string
  description = "The name of the SNS topic."
}

variable "subscription_endpoints" {
  type        = list(string)
  description = "List of email addresses to subscribe to the SNS topic."
}
