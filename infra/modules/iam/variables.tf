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
