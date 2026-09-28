resource "aws_dynamodb_table" "survey_table" {
  name         = "survey-rewards-data"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"
  range_key    = "SK"

  attribute {
    name = "PK"
    type = "S"
  }
  attribute {
    name = "SK"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Project     = "serverless-survey-api"
    Environment = "dev"
  }
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.survey_table.name
}

output "dynamo_table_arn" {
  value = aws_dynamodb_table.survey_table.arn
}