# modules/sqs/outputs.tf

output "queue_url" {
  description = "The URL of the created SQS queue"
  value       = aws_sqs_queue.this.id
}

output "queue_arn" {
  description = "The ARN of the SQS queue"
  value       = aws_sqs_queue.this.arn
}
output "dlq_url" {
  description = "URL of the Dead Letter Queue"
  value       = aws_sqs_queue.dlq.id
}

output "dlq_arn" {
  description = "ARN of the Dead Letter Queue"
  value       = aws_sqs_queue.dlq.arn
}
output "queue_name" {
  description = "The name of the SQS queue"
  value       = aws_sqs_queue.this.name
}