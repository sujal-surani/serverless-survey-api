# 1. Dead Letter Queue (Holds messages that fail processing)

resource "aws_sqs_queue" "reward_dlq"{
    name = "reward-fulfillment-dlq"
    message_retention_seconds = 1209600 # 14 days
}

# 2. Primary Processing Queue