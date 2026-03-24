resource "aws_sqs_queue" "this" {
  name                       = var.queue_name
  visibility_timeout_seconds = var.visibility_timeout
  delay_seconds              = var.delay_seconds
  kms_master_key_id           = var.kms_key_id

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })
}
# DLQ queue
resource "aws_sqs_queue" "dlq" {
  name                       = "${var.queue_name}-dlq"
  visibility_timeout_seconds = var.visibility_timeout
  kms_master_key_id           = var.kms_key_id
}