resource "aws_sns_topic" "cloudfront_alerts" {
  provider = aws.us_east_1
  name     = "spotify-app-dev-cloudfront-alerts"

  tags = {
    Environment = "dev"
    Project     = "spotify-app"
    Component   = "observability"
  }
}

resource "aws_sns_topic_subscription" "cloudfront_email" {
  provider  = aws.us_east_1
  count     = var.alarm_notification_email == null ? 0 : 1
  topic_arn = aws_sns_topic.cloudfront_alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_notification_email
}