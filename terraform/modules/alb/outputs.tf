output "alb_arn" {
  value = aws_lb.this.arn
}

output "alb_dns" {
  value = aws_lb.this.dns_name
}