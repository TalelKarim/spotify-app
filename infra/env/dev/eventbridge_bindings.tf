
# sqs link to eventbridge
resource "aws_cloudwatch_event_target" "eventbridge_to_sqs" {
  rule           = module.eventbridge.rule_name
  event_bus_name = module.eventbridge.bus_name
  arn            = module.listening_events_queue.queue_arn
}

resource "aws_cloudwatch_event_target" "to_stepfn" {
  rule           = module.track_played_to_stepfn.rule_name
  event_bus_name = module.eventbridge_bus.name
  arn            = module.analytics_state_machine.arn
  role_arn       = module.iam.eventbridge_stepfn_role_arn
}
