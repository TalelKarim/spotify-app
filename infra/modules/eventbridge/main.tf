resource "aws_cloudwatch_event_bus" "this" {
  name = var.bus_name
}

resource "aws_cloudwatch_event_rule" "this" {
  name           = var.rule_name
  event_bus_name = aws_cloudwatch_event_bus.this.name

  event_pattern = var.event_pattern
}
