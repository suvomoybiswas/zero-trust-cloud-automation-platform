variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zone" {
  description = "AWS Availability Zone"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR"
  type        = string
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR"
  type        = string
}