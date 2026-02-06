locals {
  orchestration_lambda_arns = [
    for _, m in module.orchestration_lambdas : m.lambda_arn
  ]
}

module "iam" {
  source = "../../modules/iam"

  project_name  = var.project_name
  sqs_queue_arn = module.listening_events_queue.queue_arn
  orchestration_lambda_arns = local.orchestration_lambda_arns

  dynamodb_table_arns = {
    api = [
      module.dynamodb.tracks_table_arn,
      module.dynamodb.users_table_arn
    ]

    events = [
      module.dynamodb.listening_events_table_arn,
      module.dynamodb.tracks_table_arn
    ]

    orch = [
      module.dynamodb.tracks_table_arn,
      module.dynamodb.users_table_arn,
      module.dynamodb.analytics_table_arn
    ]
  }
}
