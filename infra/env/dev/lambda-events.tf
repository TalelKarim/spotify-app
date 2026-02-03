locals {
  event_lambdas = {
    event_store_listening_event = {
      role = module.iam.lambda_events_role_arn

      env = {
        LISTENING_EVENTS_TABLE = module.dynamodb.listening_events_table_name
      }

      sqs_link = true
    }

    event_update_track_stats = {
      role = module.iam.lambda_events_role_arn

      env = {
        TRACKS_TABLE = module.dynamodb.tracks_table_name
      }

      sqs_link       = false
      sqs_queue_arns = []
    }

    event_publish_notifications = {
      role = module.iam.lambda_events_role_arn

      env = {}

      sqs_link       = false
      sqs_queue_arns = []
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

  sqs_link = each.value.sqs_link
}


resource "aws_lambda_event_source_mapping" "event_consumers" {
  for_each = {
    for k, v in local.event_lambdas :
    k => v if v.sqs_link
  }

  event_source_arn = module.listening_events_queue.queue_arn
  function_name    = module.event_lambdas[each.key].lambda_arn
  batch_size       = 10
}
