variable "alarm_notification_email" {
  type        = string
  default     = null
  description = "Email de réception des alertes SNS. L'abonnement devra être confirmé manuellement."
}

variable "api_gateway_name" {
  type        = string
  default     = "spotify-dev-api"
  description = "Nom API Gateway visible dans CloudWatch."
}

variable "api_stage_name" {
  type        = string
  default     = "dev"
  description = "Nom du stage API Gateway."
}

variable "lambda_function_names" {
  type        = list(string)
  description = "Liste exacte des noms de fonctions Lambda à monitorer."
}

variable "sqs_queue_name" {
  type        = string
  description = "Nom exact de la queue SQS principale."
}

variable "dynamodb_table_names" {
  type        = list(string)
  description = "Liste exacte des tables DynamoDB à monitorer."
}