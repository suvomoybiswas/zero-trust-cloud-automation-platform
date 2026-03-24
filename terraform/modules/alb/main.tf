resource "aws_lb" "this" {
  name = var.name
  internal = false
  load_balancer_type = "application"
  subnets = var.subnet_ids
  security_groups = [var.security_group_id]
}
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port = 80
  protocol = "HTTP"

    default_action {
        type = "fixed-response"
        fixed_response {
        content_type = "text/plain"
        message_body = "Hello from ALB!"
        status_code = "200"
        }
    }

}