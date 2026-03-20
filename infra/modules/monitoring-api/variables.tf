variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "api_gateway_name" {
  type = string
}

variable "api_stage_name" {
  type = string
}

variable "alarm_topic_arn" {
  type = string
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