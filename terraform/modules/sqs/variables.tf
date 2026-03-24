# modules/sqs/variables.tf

variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
}

variable "visibility_timeout" {
  description = "Time in seconds a message stays hidden after being picked up"
  type        = number
  default     = 30
}

variable "delay_seconds" {
  description = "Delay in seconds for messages to become visible"
  type        = number
  default     = 0
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}
variable "max_receive_count" {
  description = "Number of times a message is retried before going to DLQ"
  type        = number
  default     = 5
}