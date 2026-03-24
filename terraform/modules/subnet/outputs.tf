output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value = aws_subnet.private.id
}