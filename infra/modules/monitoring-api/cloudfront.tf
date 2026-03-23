resource "aws_cloudfront_monitoring_subscription" "frontend" {
  provider        = aws.us_east_1
  count           = var.enable_cloudfront_additional_metrics ? 1 : 0
  distribution_id = var.frontend_distribution_id

  monitoring_subscription {
    realtime_metrics_subscription_config {
      realtime_metrics_subscription_status = "Enabled"
    }
  }
}

resource "aws_cloudfront_monitoring_subscription" "media" {
  provider        = aws.us_east_1
  count           = var.enable_cloudfront_additional_metrics ? 1 : 0
  distribution_id = var.media_distribution_id

  monitoring_subscription {
    realtime_metrics_subscription_config {
      realtime_metrics_subscription_status = "Enabled"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "frontend_cloudfront_5xx" {
  provider            = aws.us_east_1
  alarm_name          = "${var.project}-${var.env}-frontend-cloudfront-5xx"
  alarm_description   = "Frontend CloudFront 5xx error rate > 1%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 1
  period              = 300
  statistic           = "Average"
  namespace           = "AWS/CloudFront"
  metric_name         = "5xxErrorRate"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DistributionId = var.frontend_distribution_id
    Region         = "Global"
  }

  alarm_actions = [var.cloudfront_alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "media_cloudfront_5xx" {
  provider            = aws.us_east_1
  alarm_name          = "${var.project}-${var.env}-media-cloudfront-5xx"
  alarm_description   = "Media CloudFront 5xx error rate > 1%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 1
  period              = 300
  statistic           = "Average"
  namespace           = "AWS/CloudFront"
  metric_name         = "5xxErrorRate"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DistributionId = var.media_distribution_id
    Region         = "Global"
  }

  alarm_actions = [var.cloudfront_alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "frontend_cloudfront_origin_latency" {
  provider            = aws.us_east_1
  count               = var.enable_cloudfront_additional_metrics ? 1 : 0
  alarm_name          = "${var.project}-${var.env}-frontend-cloudfront-origin-latency-p95"
  alarm_description   = "Frontend CloudFront origin latency p95 > 1500 ms"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 1500
  period              = 300
  extended_statistic  = "p95"
  namespace           = "AWS/CloudFront"
  metric_name         = "OriginLatency"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DistributionId = var.frontend_distribution_id
    Region         = "Global"
  }

  alarm_actions = [var.cloudfront_alarm_topic_arn]

  depends_on = [aws_cloudfront_monitoring_subscription.frontend]
}

resource "aws_cloudwatch_metric_alarm" "media_cloudfront_origin_latency" {
  provider            = aws.us_east_1
  count               = var.enable_cloudfront_additional_metrics ? 1 : 0
  alarm_name          = "${var.project}-${var.env}-media-cloudfront-origin-latency-p95"
  alarm_description   = "Media CloudFront origin latency p95 > 1500 ms"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 1500
  period              = 300
  extended_statistic  = "p95"
  namespace           = "AWS/CloudFront"
  metric_name         = "OriginLatency"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DistributionId = var.media_distribution_id
    Region         = "Global"
  }

  alarm_actions = [var.cloudfront_alarm_topic_arn]

  depends_on = [aws_cloudfront_monitoring_subscription.media]
}

resource "aws_cloudwatch_metric_alarm" "cloudfront_function_execution_errors" {
  provider            = aws.us_east_1
  count               = var.cloudfront_function_name == null ? 0 : 1
  alarm_name          = "${var.project}-${var.env}-cloudfront-function-execution-errors"
  alarm_description   = "CloudFront Function execution errors > 0"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  period              = 300
  statistic           = "Sum"
  namespace           = "AWS/CloudFront"
  metric_name         = "FunctionExecutionErrors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = var.cloudfront_function_name
    Region       = "Global"
  }

  alarm_actions = [var.cloudfront_alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "cloudfront_function_validation_errors" {
  provider            = aws.us_east_1
  count               = var.cloudfront_function_name == null ? 0 : 1
  alarm_name          = "${var.project}-${var.env}-cloudfront-function-validation-errors"
  alarm_description   = "CloudFront Function validation errors > 0"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  period              = 300
  statistic           = "Sum"
  namespace           = "AWS/CloudFront"
  metric_name         = "FunctionValidationErrors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = var.cloudfront_function_name
    Region       = "Global"
  }

  alarm_actions = [var.cloudfront_alarm_topic_arn]
}