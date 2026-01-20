variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for DynamoDB encryption"
  type        = string
}
