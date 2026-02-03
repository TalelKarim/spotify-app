resource "aws_cloudwatch_event_rule" "this" {
  name           = var.rule_name
  event_bus_name = var.bus_name
  event_pattern  = var.event_pattern
}
