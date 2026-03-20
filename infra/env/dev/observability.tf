module "observability_core" {
  source = "../../modules/observability-core"

  project                  = "spotify-app"
  env                      = "dev"
  region                   = "eu-west-1"
  alarm_notification_email = var.alarm_notification_email

  api_gateway_name      = var.api_gateway_name
  api_stage_name        = var.api_stage_name
  lambda_function_names = var.lambda_function_names
  sqs_queue_name        = var.sqs_queue_name
  dynamodb_table_names  = var.dynamodb_table_names
}

module "monitoring_api" {
  source = "../../modules/monitoring-api"

  project          = "spotify-app"
  env              = "dev"
  api_gateway_name = var.api_gateway_name
  api_stage_name   = var.api_stage_name
  alarm_topic_arn  = module.observability_core.sns_topic_arn
}

module "monitoring_compute_data" {
  source = "../../modules/monitoring-compute-data"

  project               = "spotify-app"
  env                   = "dev"
  lambda_function_names = var.lambda_function_names
  sqs_queue_name        = var.sqs_queue_name
  dynamodb_table_names  = var.dynamodb_table_names
  alarm_topic_arn       = module.observability_core.sns_topic_arn
}