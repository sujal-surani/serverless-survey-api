# 1. Zip the Python code
data "archive_file" "validation_lambda_zip" {
  type        = "zip"
  source_dir  = "../src/validation"
  output_path = "validation_lambda.zip"
}

# 2. Create the Lambda Function
resource "aws_lambda_function" "validation_lambda" {
  filename         = data.archive_file.validation_lambda_zip.output_path
  function_name    = "survey-validation-function"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "main.handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.validation_lambda_zip.output_base64sha256

  # Pass infrastructure names as environment variables
  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.survey_table.name
      SQS_QUEUE_URL       = aws_sqs_queue.rewards_queue.url
    }
  }
}

# 3. Create the Execution Role
resource "aws_iam_role" "lambda_execution_role" {
  name = "validation-lambda-execution-role"

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

# 4. Grant strict permissions to write to DB and SQS
resource "aws_iam_role_policy" "lambda_policy" {
  name = "validation-lambda-policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem"
        ]
        Resource = aws_dynamodb_table.survey_table.arn
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage"
        ]
        Resource = aws_sqs_queue.rewards_queue.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# infrastructure/lambda.tf (append to bottom)

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.validation_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* restricts invocation to ONLY this specific API Gateway
  source_arn = "${aws_apigatewayv2_api.survey_api.execution_arn}/*/*"
}