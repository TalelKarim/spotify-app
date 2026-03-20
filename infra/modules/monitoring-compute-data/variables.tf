variable "project" {
  type = string
}

variable "env" {
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

variable "alarm_topic_arn" {
  type = string
}