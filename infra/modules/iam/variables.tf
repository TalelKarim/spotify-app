variable "project_name" {
  description = "Project name used as prefix for IAM resources"
  type        = string
}


variable "sqs_queue_arn" {
  type = string
}