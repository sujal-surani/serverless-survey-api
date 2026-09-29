#1 Create HTTP API gateway 
resource "aws_apigatewayv2_api" "survey_api" {
  name          = "survey-rewards-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["content-type"]
  }
}


# 2. Create the Integration (Connects Gateway to Lambda)
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.survey_api.id
  integration_type = "AWS_PROXY"

  integration_method = "POST"
  integration_uri    = aws_lambda_function.validation_lambda.invoke_arn

  # Required format for Lambda proxy integration
  payload_format_version = "2.0"
}

# 3. Define the Route (e.g., POST /survey)
resource "aws_apigatewayv2_route" "post_survey" {
  api_id    = aws_apigatewayv2_api.survey_api.id
  route_key = "POST /survey"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# 4. Create the Deployment Stage (e.g., /v1)
resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.survey_api.id
  name        = "v1"
  auto_deploy = true
}

# 5. Output the final public URL
output "api_endpoint" {
  value = "${aws_apigatewayv2_api.survey_api.api_endpoint}/${aws_apigatewayv2_stage.api_stage.name}/survey"
}