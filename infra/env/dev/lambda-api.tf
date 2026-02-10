locals {
  api_lambdas = {
    api_get_track = {
      role = module.iam.lambda_api_role_arn
      env = {
        TRACKS_TABLE = module.dynamodb.tracks_table_name
      }
    }

    api_get_user = {
      role = module.iam.lambda_api_role_arn
      env = {
        USERS_TABLE = module.dynamodb.users_table_name
      }
    }

    api_start_stream = {
      role = module.iam.lambda_api_role_arn
      env = {
        TRACKS_TABLE = module.dynamodb.tracks_table_name
        USERS_TABLE  = module.dynamodb.users_table_name
      }
    }

    api_post_listening_event = {
      role = module.iam.lambda_api_role_arn
      env  = {}
    }

    api_search = {
      role = module.iam.lambda_api_role_arn
      env  = {}
    }
  }
}

module "api_lambdas" {
  source   = "../../modules/lambda"
  for_each = local.api_lambdas

  function_name = "spotify-dev-${each.key}"
  role_arn      = each.value.role
  handler       = "handler.main"
  package_path  = "../../../app/lambdas/dist/${each.key}.zip"

  environment_variables = each.value.env
}


resource "aws_lambda_permission" "api_permissions" {
  for_each = {
    get_track            = { lambda = "api_get_track", path = "GET/tracks/*" }
    play_track           = { lambda = "api_start_stream", path = "POST/tracks/*/play" }
    get_user             = { lambda = "api_get_user", path = "GET/users/*" }
    post_listening_event = { lambda = "api_post_listening_event", path = "POST/events/listening" }
    search               = { lambda = "api_search", path = "GET/search" }
  }

  statement_id  = "AllowApiGatewayInvoke-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = module.api_lambdas[each.value.lambda].lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.execution_arn}/*/${each.value.path}"
}
