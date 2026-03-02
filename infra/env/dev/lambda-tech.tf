locals {
  tech_lambdas = {
    tech_ingest_audio_metadata = {
      role = module.iam.lambda_tech_role_arn
      env = {
        TRACKS_TABLE = module.dynamodb.tracks_table_name
      }
    }

    tech_reindex_opensearch = {
      role = module.iam.lambda_tech_role_arn
      env = {
        OPENSEARCH_ENDPOINT = module.opensearch.domain_endpoint
        OPENSEARCH_INDEX    = "tracks"
      }
      vpc_enabled = true
    }

    tech_show_index_opensearch = {
      role = module.iam.lambda_tech_role_arn
      env = {
        OPENSEARCH_ENDPOINT = module.opensearch.domain_endpoint
      }
      vpc_enabled = true
    }
  }

  tracks_stream_arn = module.dynamodb.tracks_table_stream_arn

}



module "tech_lambdas" {
  source   = "../../modules/lambda"
  for_each = local.tech_lambdas

  function_name = "spotify-dev-${each.key}"
  role_arn      = each.value.role
  handler       = "handler.main"
  package_path  = "../../../app/lambdas/dist/${each.key}.zip"

  #vpc conf 
  subnet_ids = lookup(each.value, "vpc_enabled", false) ? module.vpc.private_subnets_ids : []

  security_group_ids = lookup(each.value, "vpc_enabled", false) ? [aws_security_group.lambda_search.id] : []


  layers = contains( ["tech_reindex_opensearch", "tech_show_index_opensearch"], each.key) ? [aws_lambda_layer_version.python_requests.arn] : []
  environment_variables = each.value.env
}
