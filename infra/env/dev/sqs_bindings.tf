
# sqs link to eventbridge
resource "aws_cloudwatch_event_target" "eventbridge_to_sqs" {
  rule           = module.eventbridge.rule_name
  event_bus_name = module.eventbridge.bus_name
  arn            = module.listening_events_queue.queue_arn
}




resource "aws_lambda_event_source_mapping" "sqs_to_event_lambda" {
  event_source_arn = module.listening_events_queue.queue_arn
  function_name    = module.event_lambdas["event_store_listening_event"].lambda_arn
  batch_size       = 10
}
