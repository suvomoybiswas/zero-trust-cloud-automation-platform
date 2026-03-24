output "frontend_sg" {
  value = aws_security_group.frontend.id
}
output "api_sg" {
  value = aws_security_group.api.id
}
output "worker_sg" {
  value = aws_security_group.worker.id
}
