resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each = toset(var.lambda_function_names)

  alarm_name          = "${each.value}-errors"
  alarm_description   = "Lambda errors > 0 sur 5 minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  period              = 300
  statistic           = "Sum"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = each.value
  }

  alarm_actions = [var.alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration_p95" {
  for_each = toset(var.lambda_function_names)

  alarm_name          = "${each.value}-duration-p95"
  alarm_description   = "Lambda p95 duration > 3000 ms sur 10 minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 3000
  period              = 300
  extended_statistic  = "p95"
  namespace           = "AWS/Lambda"
  metric_name         = "Duration"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = each.value
  }

  alarm_actions = [var.alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "sqs_oldest_message_age" {
  alarm_name          = "${var.project}-${var.env}-sqs-oldest-message-age"
  alarm_description   = "Âge du plus vieux message SQS > 300 sec"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 300
  period              = 300
  statistic           = "Maximum"
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateAgeOfOldestMessage"
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = var.sqs_queue_name
  }

  alarm_actions = [var.alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "sqs_visible_messages" {
  alarm_name          = "${var.project}-${var.env}-sqs-visible-messages"
  alarm_description   = "Backlog SQS visible > 100 messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 100
  period              = 300
  statistic           = "Maximum"
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = var.sqs_queue_name
  }

  alarm_actions = [var.alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_read_throttle" {
  for_each = toset(var.dynamodb_table_names)

  alarm_name          = "${each.value}-read-throttle"
  alarm_description   = "Read throttles > 0"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  period              = 300
  statistic           = "Sum"
  namespace           = "AWS/DynamoDB"
  metric_name         = "ReadThrottleEvents"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = each.value
  }

  alarm_actions = [var.alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_write_throttle" {
  for_each = toset(var.dynamodb_table_names)

  alarm_name          = "${each.value}-write-throttle"
  alarm_description   = "Write throttles > 0"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  period              = 300
  statistic           = "Sum"
  namespace           = "AWS/DynamoDB"
  metric_name         = "WriteThrottleEvents"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = each.value
  }

  alarm_actions = [var.alarm_topic_arn]
}