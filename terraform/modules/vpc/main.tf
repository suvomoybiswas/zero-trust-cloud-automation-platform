resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    tags ={
        Name = "zero-trust-vpc"
    }
}
resource "aws_cloudwatch_log_group" "flow_logs" {
  name = "/vpc/flow-logs"
}
resource "aws_iam_role" "flow_logs_role" {
  name = "flow-logs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy" "flow_logs_policy" {
  role = aws_iam_role.flow_logs_role.id
  policy = jsonencode({
    Version ="2012-10-17"
    Statement = [{
        Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = "*"
    }]
  })
}
resource "aws_flow_log" "vpc_flow_logs" {
 vpc_id = aws_vpc.main.id 
 traffic_type = "ALL"

   log_destination = aws_cloudwatch_log_group.flow_logs.arn
   iam_role_arn = aws_iam_role.flow_logs_role.arn
}