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


  lambda_log_group_names = concat(
    [for m in values(module.api_lambdas) : m.log_group_name],
    [for m in values(module.event_lambdas) : m.log_group_name],
    [for m in values(module.orchestration_lambdas) : m.log_group_name],
    [for m in values(module.tech_lambdas) : m.log_group_name]
  )


  api_access_log_group_name = module.monitoring_api.api_gateway_access_log_group_name

  step_functions_log_group_name = module.listening_analytics.log_group_name

  frontend_distribution_id             = module.frontend.cloudfront_distribution_id
  media_distribution_id                = module.media.cloudfront_distribution_id
  cloudfront_function_name             = module.frontend.cloudfront_function_name
  enable_cloudfront_additional_metrics = var.enable_cloudfront_additional_metrics

  state_machine_arn      = module.listening_analytics.state_machine_arn
  event_bus_name         = module.eventbridge_bus.bus_name
  eventbridge_rule_names = [module.rule_track_played_to_sqs.rule_name, module.rule_track_played_to_stepfn.rule_name]
  opensearch_domain_name = module.opensearch.domain_name
}

module "monitoring_api" {
  source = "../../modules/monitoring-api"


  project                    = "spotify-app"
  env                        = "dev"
  api_gateway_name           = var.api_gateway_name
  api_stage_name             = var.api_stage_name
  alarm_topic_arn            = module.observability_core.sns_topic_arn
  cloudfront_alarm_topic_arn = aws_sns_topic.cloudfront_alerts.arn


  frontend_distribution_id             = module.frontend.cloudfront_distribution_id
  media_distribution_id                = module.media.cloudfront_distribution_id
  cloudfront_function_name             = module.frontend.cloudfront_function_name
  enable_cloudfront_additional_metrics = var.enable_cloudfront_additional_metrics
}

module "monitoring_compute_data" {
  source = "../../modules/monitoring-compute-data"

  project               = "spotify-app"
  env                   = "dev"
  lambda_function_names = var.lambda_function_names
  sqs_queue_name        = var.sqs_queue_name
  dynamodb_table_names  = var.dynamodb_table_names
  alarm_topic_arn       = module.observability_core.sns_topic_arn

  dlq_queue_name                        = module.listening_events_queue.dlq_queue_name
  state_machine_arn                     = module.listening_analytics.state_machine_arn
  event_bus_name                        = module.eventbridge_bus.bus_name
  eventbridge_rule_names                = [module.rule_track_played_to_sqs.rule_name, module.rule_track_played_to_stepfn.rule_name]
  opensearch_domain_name                = module.opensearch.domain_name
  opensearch_free_storage_threshold_mib = var.opensearch_free_storage_threshold_mib
}