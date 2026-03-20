variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "alarm_notification_email" {
  type    = string
  default = null
}

variable "api_gateway_name" {
  type = string
}

variable "api_stage_name" {
  type = string
}

variable "lambda_function_names" {
  type = list(string)
}

variable "sqs_queue_name" {
  type = string
}

variable "dynamodb_table_names" {
  type = list(string)
}



variable "frontend_distribution_id" {
  type = string
}

variable "media_distribution_id" {
  type = string
}

variable "cloudfront_function_name" {
  type    = string
  default = null
}

variable "enable_cloudfront_additional_metrics" {
  type    = bool
  default = false
}

variable "state_machine_arn" {
  type = string
}

variable "event_bus_name" {
  type = string
}

variable "eventbridge_rule_names" {
  type = list(string)
}

variable "opensearch_domain_name" {
  type = string
}


output "edge_access_dashboard_name" {
  value = aws_cloudwatch_dashboard.edge_access.dashboard_name
}

output "async_search_dashboard_name" {
  value = aws_cloudwatch_dashboard.async_search.dashboard_name
}