resource "aws_apigatewayv2_api" "email_processing_api" {
  name          = "${var.env}-email-processing-api"
  protocol_type = "HTTP"
  description   = "HTTP API Gateway for ${var.env} Email Processing Lambda"
#   target        = aws_lambda_function.auth_lambda.arn

  tags = {
    Environment = "${var.env}"
  }
}

resource "aws_apigatewayv2_integration" "lambda_auth" {
  api_id                 = aws_apigatewayv2_api.email_processing_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.auth_lambda.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "post_inboundparse" {
  api_id    = aws_apigatewayv2_api.email_processing_api.id
  route_key = "POST /inboundparse"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_auth.id}"
}
