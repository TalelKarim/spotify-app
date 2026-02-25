variable "project_name" {
  description = "Project name used as prefix for IAM resources"
  type        = string
}


variable "sqs_queue_arn" {
  type = string
}



variable "orchestration_lambda_arns" {
  description = "ARNs des lambdas d’orchestration invoquées par Step Functions"
  type        = list(string)
}

variable "dynamodb_table_arns" {
  description = "ARNs des tables DynamoDB utilisées par les lambdas"
  type = object({
    api    = list(string)
    events = list(string)
    orch   = list(string)
  })
}


variable "media_bucket_name" {
  type = string
}


variable "eventbridge_bus_arn" {
  description = "ARN of the EventBridge bus"
  type        = string
}



variable "tracks_stream_arn" {
  type = string
}


variable "opensearch_domain_arn" {
  type = string
}