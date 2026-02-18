module "dynamodb" {
  source = "../../modules/dynamodb"

  project_name = var.project_name
  kms_key_arn  = module.kms.kms_key_arn
}


resource "aws_lambda_event_source_mapping" "tracks_to_opensearch" {
  event_source_arn  = module.dynamodb.tracks_table_stream_arn
  function_name     = module.tech_lambdas["tech_reindex_opensearch"].lambda_arn

  starting_position      = "LATEST"
  batch_size             = 100
  maximum_retry_attempts = 3

  enabled = true
}
