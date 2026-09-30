data "archive_file" "status_lambda_zip" {
  type        = "zip"
  source_dir  = "../src/status"
  output_path = "status_lambda.zip"
}

resource "aws_lambda_function" "status_worker" {
  filename         = data.archive_file.status_lambda_zip.output_path
  function_name    = "survey-status-checker"
  role             = aws_iam_role.status_role.arn
  handler          = "main.handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.status_lambda_zip.output_base64sha256
}

resource "aws_iam_role" "status_role" {
  name = "status-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}

# API Gateway Integration
resource "aws_apigatewayv2_integration" "status_integration" {
  api_id           = aws_apigatewayv2_api.survey_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.status_worker.invoke_arn
}

# The GET Route with the path parameter {transaction_id}
resource "aws_apigatewayv2_route" "status_route" {
  api_id    = aws_apigatewayv2_api.survey_api.id
  route_key = "GET /survey/{transaction_id}"
  target    = "integrations/${aws_apigatewayv2_integration.status_integration.id}"
}

# Permission for API Gateway to invoke this specific Lambda
resource "aws_lambda_permission" "api_gw_status" {
  statement_id  = "AllowExecutionFromAPIGatewayGET"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.status_worker.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.survey_api.execution_arn}/*/*"
}