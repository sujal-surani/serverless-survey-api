# resource "aws_lambda_event_source_mapping" "sqs_trigger" {
#   event_source_arn = aws_sqs_queue.rewards_queue.arn
#   function_name    = aws_lambda_function.fulfillment_worker.arn
#   batch_size       = 1
# }