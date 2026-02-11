locals {
  orchestration_lambdas = {
    orch_update_track_stats = {
      role = module.iam.lambda_step_functions_role_arn
      env = {

        TRACKS_TABLE = module.dynamodb.tracks_table_name
      }
    }

    orch_update_user_stats = {
      role = module.iam.lambda_step_functions_role_arn
      env = {
        USERS_TABLE = module.dynamodb.users_table_name
      }
    }


    orch_compute_analytics = {
      role = module.iam.lambda_step_functions_role_arn
      env = {
        LISTENING_EVENTS_TABLE = module.dynamodb.listening_events_table_name
      }
    }
  }
}

module "orchestration_lambdas" {
  source   = "../../modules/lambda"
  for_each = local.orchestration_lambdas

  function_name = "spotify-dev-${each.key}"
  role_arn      = each.value.role
  handler       = "handler.main"
  package_path  = "../../../app/lambdas/dist/${each.key}.zip"

  environment_variables = each.value.env
}
