# modules/lambda/variables.tf

variable "function_name" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}

variable "handler" {
  type = string
}

variable "runtime" {
  type    = string
  default = "python3.10"
}

variable "filename" {
  type = string
}

variable "timeout" {
  type    = number
  default = 10
}
variable "environment_variables" {
  type        = map(string)
  default     = {}
  description = "Environment variables to pass to Lambda"
}