locals {
  api_lambdas = {
    api_get_track = {
      role = module.iam.lambda_api_role_arn
      env = {
        TRACKS_TABLE      = module.dynamodb.tracks_table_name
        CLOUDFRONT_DOMAIN = module.media.cloudfront_domain
      }
    }

    api_get_tracks = {
      role = module.iam.lambda_api_role_arn
      env = {
        TRACKS_TABLE      = module.dynamodb.tracks_table_name
        CLOUDFRONT_DOMAIN = module.media.cloudfront_domain
      }
    }

    api_get_me_recently_played = {
    role = module.iam.lambda_api_role_arn
    env = {
      LISTENING_EVENTS_TABLE = module.dynamodb.listening_events_table_name
      TRACKS_TABLE           = module.dynamodb.tracks_table_name
      CLOUDFRONT_DOMAIN      = module.media.cloudfront_domain
    }
  }


    api_create_track = {
      role = module.iam.lambda_api_role_arn
      env = {
        TRACKS_TABLE  = module.dynamodb.tracks_table_name
        TRACKS_BUCKET = module.media.bucket_name
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
        TRACKS_TABLE   = module.dynamodb.tracks_table_name
        USERS_TABLE    = module.dynamodb.users_table_name
        EVENT_BUS_NAME = module.eventbridge_bus.bus_name
      }
    }

    api_post_listening_event = {
      role = module.iam.lambda_api_role_arn
      env  = {}
    }

    api_get_analytics = {
      role = module.iam.lambda_api_role_arn
      env = {
        ANALYTICS_TABLE = module.dynamodb.analytics_table_name
      }

    }


    api_search = {
      role = module.iam.lambda_api_role_arn
      env = {
        TRACKS_TABLE        = module.dynamodb.tracks_table_name
        OPENSEARCH_ENDPOINT = module.opensearch.domain_endpoint
        OPENSEARCH_INDEX    = "tracks"
      }
      vpc_enabled = true
    }

    api_get_track_stats = {
      role = module.iam.lambda_api_role_arn
      env = {
        TRACKS_TABLE = module.dynamodb.tracks_table_name
      }
    }


    api_get_me = {
      role = module.iam.lambda_api_role_arn
      env  = {}
    }

    api_get_myhistory = {
      role = module.iam.lambda_api_role_arn
      env = {
        LISTENING_EVENTS_TABLE = module.dynamodb.listening_events_table_name
      }
    }


    api_healthcheck = {
      role = module.iam.lambda_api_role_arn
      env = {
      }
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


  #vpc conf 
  subnet_ids = lookup(each.value, "vpc_enabled", false) ? module.vpc.private_subnets_ids : []

  security_group_ids = lookup(each.value, "vpc_enabled", false) ? [aws_security_group.lambda_search.id] : []

  environment_variables = merge(
    each.value.env,
    {
      ALLOWED_ORIGIN = var.frontend_origin
    }
  )

  layers = contains(["api_search"], each.key) ? [aws_lambda_layer_version.python_requests.arn] : []
}


resource "aws_lambda_permission" "api_permissions" {
  for_each = {
    get_track       = { lambda = "api_get_track", path = "GET/tracks/*" }
    get_tracks      = { lambda = "api_get_tracks", path = "GET/tracks*" }
    get_track_stats = { lambda = "api_get_track_stats", path = "GET/tracks/*" }
    health          = { lambda = "api_healthcheck", path = "GET/health" }


    get_me_recently_played = { lambda = "api_get_me_recently_played", path = "GET/me/recently-played" }
    get_my_history       = { lambda = "api_get_myhistory", path = "GET/me/listening/history" }
    get_analytics        = { lambda = "api_get_analytics", path = "GET/analytics/global" }
    post_track           = { lambda = "api_create_track", path = "POST/tracks" }
    get_me               = { lambda = "api_get_me", path = "GET/me" }
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
