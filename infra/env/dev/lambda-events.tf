locals {
  event_lambdas = {
    event_store_listening_event = {
      role = module.iam.lambda_events_role_arn
      env = {
        LISTENING_EVENTS_TABLE = module.dynamodb.listening_events_table_name
      }
    }

    event_update_track_stats = {
      role = module.iam.lambda_events_role_arn
      env = {
        TRACKS_TABLE = module.dynamodb.tracks_table_name
      }
    }

    event_publish_notifications = {
      role = module.iam.lambda_events_role_arn
      env  = {}
    }
  }
}

module "event_lambdas" {
  source   = "../../modules/lambda"
  for_each = local.event_lambdas

  function_name = "spotify-dev-${each.key}"
  role_arn      = each.value.role
  handler       = "handler.main"
  package_path  = "../../../app/lambdas/${each.key}.zip"

  environment_variables = each.value.env
}
