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