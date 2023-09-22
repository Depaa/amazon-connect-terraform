output "arn" {
  value       = aws_connect_instance.this.arn
  description = "ARN of the Connect instance."
}

output "id" {
  value       = aws_connect_instance.this.id
  description = "The identifier of the Connect instance."
}

output "instance_alias" {
  value       = aws_connect_instance.this.instance_alias
  description = "The instance_alias of the Connect instance."
}
