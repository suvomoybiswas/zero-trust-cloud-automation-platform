module "vpc" {
  source = "../../terraform/modules/vpc"
  vpc_cidr = var.vpc_cidr
}

module "subnet" {

  source = "../../terraform/modules/subnet"

  vpc_id                 = module.vpc.vpc_id
  public_subnet_cidr_1   = "10.0.10.0/24"
  public_subnet_cidr_2   = "10.0.30.0/24"
  private_subnet_cidr    = "10.0.20.0/24"
  availability_zone_1    = "us-east-1a"
  availability_zone_2    = "us-east-1b"
  private_az             = "us-east-1a"
}

module "security_group" {
  source = "../../terraform/modules/security_group"
  vpc_id = module.vpc.vpc_id
}

module "igw" {

  source = "../../terraform/modules/igw"

  vpc_id = module.vpc.vpc_id

}

module "route_table" {

  source = "../../terraform/modules/route_table"

  vpc_id = module.vpc.vpc_id

  igw_id = module.igw.igw_id

  public_subnet_ids = module.subnet.public_subnet_ids
  private_subnet_id = module.subnet.private_subnet_id

}
module "alb" {
  source = "../../terraform/modules/alb"
  name = "dev-alb"
  subnet_ids = module.subnet.public_subnet_ids
  security_group_id = module.security_group.frontend_sg
}
module "task_table" {
  source = "../../terraform/modules/dynamodb"
  table_name = "dev-task-table"
  hash_key = "task_id"
}
module "uploads_bucket" {
  source = "../../terraform/modules/s3"
  bucket_name = "dev-uploads-bucket505050"
}
module "task_queue" {
  source = "../../terraform/modules/sqs"
  queue_name = "dev-task-queue"
  visibility_timeout = 45
  max_receive_count = 3
}

resource "aws_iam_role" "lambda_role" {
  name = "dev-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
module "worker_lambda" {
  source = "../../terraform/modules/lambda"
  function_name = "dev-worker"
  lambda_role_arn = aws_iam_role.lambda_role.arn
  handler = "app.lambda_handler"
  runtime = "python3.10"
  filename = "../../terraform/modules/lambda/worker.zip"
  timeout = 10

  # Pass shared resources
  environment_variables = {
    TABLE_NAME = module.task_table.table_name
    BUCKET_NAME = module.uploads_bucket.bucket_name
    QUEUE_URL = module.task_queue.queue_url
  }
  }
resource "aws_iam_role_policy" "lambda_sqs_policy" {
  name = "lambda-sqs-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = module.task_queue.queue_arn
      }
    ]
  })
}
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = module.task_queue.queue_arn
  function_name    = module.worker_lambda.lambda_arn
  batch_size       = 1
}
module "api_lambda" {
  source = "../../terraform/modules/lambda"
  function_name = "dev-api-lambda"
  lambda_role_arn = aws_iam_role.lambda_role.arn
  handler = "api_handler.lambda_handler"
  runtime = "python3.10"
  filename = "../../terraform/modules/lambda/api_lambda.zip"
  timeout = 10
  environment_variables = {
    QUEUE_URL = module.task_queue.queue_url
  }
}
resource "aws_lambda_permission" "api_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway" 
  action        = "lambda:InvokeFunction"      
  function_name = module.api_lambda.lambda_name
  principal     = "apigateway.amazonaws.com"  
}
module "api_gateway" {
 source = "../../terraform/modules/api_gateway"
 api_name = "dev-api"
  lambda_arn = module.api_lambda.lambda_arn 
    region = "us-east-1"
    user_pool_id = "us-east-1_YfWq9s75U"
  user_pool_client_id = "39st0thplb9dur2jo54f2qcruc"
}
resource "aws_lambda_permission" "allow_s3" {
  statement_id = "AllowS3Invoke"
  action = "lambda:InvokeFunction"
  function_name = module.worker_lambda.lambda_name
  principal = "s3.amazonaws.com"
  source_arn = module.uploads_bucket.bucket_arn
}
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.uploads_bucket.bucket_name

  lambda_function {
    lambda_function_arn = module.worker_lambda.lambda_arn
    events = [ "s3:ObjectCreated:*" ]
  }
  depends_on = [ aws_lambda_permission.allow_s3 ]
}
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "dev-worker-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  dimensions = {
    FunctionName = module.worker_lambda.lambda_name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "dev-worker-lambda-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Average"
  threshold           = 5000  # 5 seconds

  dimensions = {
    FunctionName = module.worker_lambda.lambda_name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}
resource "aws_cloudwatch_metric_alarm" "sqs_queue_depth" {
  alarm_name          = "dev-sqs-queue-depth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Average"
  threshold           = 5

  dimensions = {
    QueueName = module.task_queue.queue_name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}
resource "aws_sns_topic" "alerts" {
  name = "dev-alerts"
}
resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "biswas.suvomoy1991@gmail.com"
}
module "waf" {
  source = "../../terraform/modules/waf"
  alb_arn = module.alb.alb_arn
}

locals {
  environment = terraform.workspace
}
