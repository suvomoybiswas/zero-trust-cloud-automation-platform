variable "vpc_id" {
  description = "VPC ID for subnets"
  type        = string
}

variable "public_subnet_cidr_1" {
  description = "CIDR for public subnet 1"
  type        = string
}

variable "public_subnet_cidr_2" {
  description = "CIDR for public subnet 2"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR for private subnet"
  type        = string
}

variable "availability_zone_1" {
  description = "AZ for public subnet 1"
  type        = string
}

variable "availability_zone_2" {
  description = "AZ for public subnet 2"
  type        = string
}

variable "private_az" {
  description = "AZ for private subnet"
  type        = string
}