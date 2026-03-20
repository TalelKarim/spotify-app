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


variable "dlq_queue_name" {
  type    = string
  default = null
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

variable "opensearch_free_storage_threshold_mib" {
  type    = number
  default = 20480
}