output "name" {
  description = "Name of the Kinesis stream."
  value       = aws_kinesis_stream.this.name
}

output "arn" {
  description = "ARN of the Kinesis stream."
  value       = aws_kinesis_stream.this.arn
}
