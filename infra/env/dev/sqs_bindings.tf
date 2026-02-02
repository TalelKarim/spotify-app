
# sqs link to eventbridge
resource "aws_cloudwatch_event_target" "eventbridge_to_sqs" {
  rule          = module.eventbridge.rule_name
  event_bus_name = module.eventbridge.bus_name
  arn           = module.listening_events_queue.queue_arn
}
