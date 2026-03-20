output "lambda_alarm_names" {
  value = keys(aws_cloudwatch_metric_alarm.lambda_errors)
}