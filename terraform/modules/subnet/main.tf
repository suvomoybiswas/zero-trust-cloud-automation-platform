resource "aws_subnet" "public_1" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidr_1
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true
  tags = { Name = "zero-trust-public-subnet-1" }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidr_2
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true
  tags = { Name = "zero-trust-public-subnet-2" }
}

resource "aws_subnet" "private" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.private_az
  tags = { Name = "zero-trust-private-subnet" }
}