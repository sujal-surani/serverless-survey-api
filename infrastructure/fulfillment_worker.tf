data "archive_file" "fulfillment_lambda_zip" {
  type        = "zip"
  source_dir  = "../src/fulfillment"
  output_path = "fulfillment_lambda.zip"
}

resource "aws_lambda_function" "fulfillment_worker" {
  filename         = data.archive_file.fulfillment_lambda_zip.output_path
  function_name    = "rewards-fulfillment-worker"
  role             = aws_iam_role.fulfillment_role.arn
  handler          = "main.handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.fulfillment_lambda_zip.output_base64sha256
}

resource "aws_iam_role" "fulfillment_role" {
  name = "fulfillment-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "fulfillment_policy" {
  name = "fulfillment-sqs-policy"
  role = aws_iam_role.fulfillment_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource = aws_sqs_queue.rewards_queue.arn
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.rewards_queue.arn
  function_name    = aws_lambda_function.fulfillment_worker.arn
  batch_size       = 1
}