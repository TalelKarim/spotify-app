output "api_gateway_access_log_group_arn" {
  value = aws_cloudwatch_log_group.api_gateway_access.arn
}

output "api_gateway_access_log_group_name" {
  value = aws_cloudwatch_log_group.api_gateway_access.name
}