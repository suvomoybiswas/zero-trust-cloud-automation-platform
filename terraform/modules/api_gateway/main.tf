resource "aws_apigatewayv2_api" "this" {
  name = var.api_name
  protocol_type = "HTTP"
}
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  integration_uri = var.lambda_arn
  payload_format_version = "2.0"
}
resource "aws_apigatewayv2_route" "post_message" {
  api_id = aws_apigatewayv2_api.this.id
  route_key = "POST /send-messages"
  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.cognito.id
}
resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.this.id
  name = "$default"
  auto_deploy = true
}
resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id = aws_apigatewayv2_api.this.id
  authorizer_type = "JWT"
identity_sources = ["$request.header.Authorization"]
    
    name = "cognito_authorizer"
    jwt_configuration {
      issuer = "https://cognito-idp.${var.region}.amazonaws.com/${var.user_pool_id}"
      audience = [var.user_pool_client_id]
    }
}