resource "aws_security_group" "frontend" {
  name        = "frontend-sg"
  description = "Allow frontend inbound traffic"
  vpc_id = var.vpc_id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "api" {
  name        = "api-sg"
  description = "Allow api inbound traffic"
  vpc_id = var.vpc_id

  ingress {
    from_port        = 5000
    to_port          = 5000
    protocol         = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }
}
resource "aws_security_group" "worker" {
  name = "worker-sg"
  description = "Allow worker inbound traffic"
  vpc_id = var.vpc_id
  ingress {
    from_port        = 6379
    to_port          = 6379
    protocol         = "tcp"
    security_groups = [aws_security_group.api.id]
  }
}
