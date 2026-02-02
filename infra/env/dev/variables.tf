variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}


variable "sqs_link" {
  type    = bool
  default = false
}

variable "sqs_queue_arns" {
  type    = list(string)
  default = []
}
