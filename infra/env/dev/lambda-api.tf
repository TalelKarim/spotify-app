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
  package_path  = "../../../app/lambdas/${each.key}.zip"

  environment_variables = each.value.env
}

resource "aws_lambda_permission" "play_track" {
  statement_id  = "AllowApiGatewayInvokePlayTrack"
  action        = "lambda:InvokeFunction"
  function_name = module.api_lambdas["api_play_track"].lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.execution_arn}/*/POST/tracks/*/play"
}
