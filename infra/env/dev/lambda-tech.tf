locals {
  tech_lambdas = {
    tech_ingest_audio_metadata = {
      role = module.iam.lambda_events_role_arn
      env = {
        TRACKS_TABLE = module.dynamodb.tracks_table_name
      }
    }

    tech_reindex_opensearch = {
      role        = module.iam.lambda_events_role_arn
      env         = {}
      vpc_enabled = true
    }
  }
}

module "tech_lambdas" {
  source   = "../../modules/lambda"
  for_each = local.tech_lambdas

  function_name = "spotify-dev-${each.key}"
  role_arn      = each.value.role
  handler       = "handler.main"
  package_path  = "../../../app/lambdas/dist/${each.key}.zip"

  #vpc conf 
  subnet_ids = lookup(each.value, "vpc_enabled", false) ? module.vpc.private_subnets_ids  : []

  security_group_ids = lookup(each.value, "vpc_enabled", false)  ? [aws_security_group.lambda_search.id] : []


  environment_variables = each.value.env
}
