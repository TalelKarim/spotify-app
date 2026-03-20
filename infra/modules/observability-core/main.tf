locals {
  lambda_error_metrics = [
    for fn in var.lambda_function_names : ["AWS/Lambda", "Errors", "FunctionName", fn]
  ]

  lambda_duration_metrics = [
    for fn in var.lambda_function_names : ["AWS/Lambda", "Duration", "FunctionName", fn]
  ]

  dynamodb_read_throttle_metrics = [
    for table in var.dynamodb_table_names : ["AWS/DynamoDB", "ReadThrottleEvents", "TableName", table]
  ]

  dynamodb_write_throttle_metrics = [
    for table in var.dynamodb_table_names : ["AWS/DynamoDB", "WriteThrottleEvents", "TableName", table]
  ]
}

resource "aws_sns_topic" "alerts" {
  name = "${var.project}-${var.env}-observability-alerts"

  tags = {
    Environment = var.env
    Project     = var.project
    Component   = "observability"
  }
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.alarm_notification_email == null ? 0 : 1
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_notification_email
}

resource "aws_cloudwatch_dashboard" "global" {
  dashboard_name = "${var.project}-${var.env}-global"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "API Gateway - Count / 4XX / 5XX"
          view    = "timeSeries"
          stacked = false
          region  = var.region
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiName", var.api_gateway_name, "Stage", var.api_stage_name],
            [".", "4XXError", ".", ".", ".", "."],
            [".", "5XXError", ".", ".", ".", "."]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "API Gateway - Latency / IntegrationLatency"
          view    = "timeSeries"
          stacked = false
          region  = var.region
          metrics = [
            ["AWS/ApiGateway", "Latency", "ApiName", var.api_gateway_name, "Stage", var.api_stage_name],
            [".", "IntegrationLatency", ".", ".", ".", "."]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title   = "Lambda - Errors"
          view    = "timeSeries"
          stacked = false
          region  = var.region
          metrics = local.lambda_error_metrics
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title   = "Lambda - Duration"
          view    = "timeSeries"
          stacked = false
          region  = var.region
          metrics = local.lambda_duration_metrics
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          title   = "SQS - Backlog / Age"
          view    = "timeSeries"
          stacked = false
          region  = var.region
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", var.sqs_queue_name],
            [".", "ApproximateAgeOfOldestMessage", ".", "."]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          title   = "DynamoDB - Throttles"
          view    = "timeSeries"
          stacked = false
          region  = var.region
          metrics = concat(local.dynamodb_read_throttle_metrics, local.dynamodb_write_throttle_metrics)
        }
      }
    ]
  })
}