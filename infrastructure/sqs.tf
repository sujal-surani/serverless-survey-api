# 1. Dead Letter Queue (Holds messages that fail processing)

resource "aws_sqs_queue" "reward_dlq" {
  name                      = "reward-fulfillment-dlq"
  message_retention_seconds = 1209600 # 14 days
}

# 2. Primary Processing Queue

resource "aws_sqs_queue" "rewards_queue" {
  name                       = "rewards-fulfillment-queue"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 345600

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.reward_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Project     = "serverless-survey-api"
    Environment = "dev"
  }
}


output "sqs_queue_url" {
  value = aws_sqs_queue.rewards_queue.url
}

output "sqs_queue_arn" {
  value = aws_sqs_queue.rewards_queue.arn
}