data "aws_iam_policy_document" "apigw_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "apigw_cloudwatch_logs" {
  name               = "${var.project}-${var.env}-apigw-cloudwatch-logs-role"
  assume_role_policy = data.aws_iam_policy_document.apigw_assume_role.json

  tags = {
    Environment = var.env
    Project     = var.project
    Component   = "observability"
  }
}

resource "aws_iam_role_policy_attachment" "apigw_cloudwatch_logs" {
  role       = aws_iam_role.apigw_cloudwatch_logs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.apigw_cloudwatch_logs.arn
}

resource "aws_cloudwatch_log_group" "api_gateway_access" {
  name              = "/aws/apigateway/${var.project}-${var.env}-access"
  retention_in_days = 30

  tags = {
    Environment = var.env
    Project     = var.project
    Component   = "observability"
  }
}

resource "aws_cloudwatch_metric_alarm" "apigw_5xx" {
  alarm_name          = "${var.project}-${var.env}-apigw-5xx"
  alarm_description   = "API Gateway 5XX > 0 sur 5 minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  period              = 300
  statistic           = "Sum"
  namespace           = "AWS/ApiGateway"
  metric_name         = "5XXError"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApiName = var.api_gateway_name
    Stage   = var.api_stage_name
  }

  alarm_actions = [var.alarm_topic_arn]
  ok_actions    = [var.alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "apigw_latency_p95" {
  alarm_name          = "${var.project}-${var.env}-apigw-latency-p95"
  alarm_description   = "API Gateway p95 latency > 1500 ms sur 10 minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 1500
  period              = 300
  extended_statistic  = "p95"
  namespace           = "AWS/ApiGateway"
  metric_name         = "Latency"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApiName = var.api_gateway_name
    Stage   = var.api_stage_name
  }

  alarm_actions = [var.alarm_topic_arn]
}