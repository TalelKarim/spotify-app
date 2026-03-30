module "api_gateway" {
  source                = "../../modules/api-gateway"
  name                  = "spotify-dev-api"
  cognito_user_pool_arn = module.cognito.user_pool_arn
}

# =========================================================
# TRACKS
# =========================================================

resource "aws_api_gateway_resource" "tracks" {
  rest_api_id = module.api_gateway.id
  parent_id   = module.api_gateway.root_resource_id
  path_part   = "tracks"
}

resource "aws_api_gateway_resource" "track_id" {
  rest_api_id = module.api_gateway.id
  parent_id   = aws_api_gateway_resource.tracks.id
  path_part   = "{trackId}"
}

resource "aws_api_gateway_resource" "play" {
  rest_api_id = module.api_gateway.id
  parent_id   = aws_api_gateway_resource.track_id.id
  path_part   = "play"
}

resource "aws_api_gateway_resource" "track_stats" {
  rest_api_id = module.api_gateway.id
  parent_id   = aws_api_gateway_resource.track_id.id
  path_part   = "stats"
}

# ---------------------------------------------------------
# POST /tracks
# ---------------------------------------------------------

resource "aws_api_gateway_method" "post_track" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.tracks.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = module.api_gateway.authorizer_id
}

resource "aws_api_gateway_integration" "post_track" {
  rest_api_id             = module.api_gateway.id
  resource_id             = aws_api_gateway_resource.tracks.id
  http_method             = aws_api_gateway_method.post_track.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.api_lambdas["api_create_track"].invoke_arn
}

# ---------------------------------------------------------
# GET /tracks
# ---------------------------------------------------------

resource "aws_api_gateway_method" "get_tracks" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.tracks.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_tracks" {
  rest_api_id             = module.api_gateway.id
  resource_id             = aws_api_gateway_resource.tracks.id
  http_method             = aws_api_gateway_method.get_tracks.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.api_lambdas["api_get_tracks"].invoke_arn
}

# ---------------------------------------------------------
# GET /tracks/{trackId}
# ---------------------------------------------------------

resource "aws_api_gateway_method" "get_track" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.track_id.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_track" {
  rest_api_id             = module.api_gateway.id
  resource_id             = aws_api_gateway_resource.track_id.id
  http_method             = aws_api_gateway_method.get_track.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.api_lambdas["api_get_track"].invoke_arn
}

# ---------------------------------------------------------
# POST /tracks/{trackId}/play
# ---------------------------------------------------------

resource "aws_api_gateway_method" "play_track" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.play.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = module.api_gateway.authorizer_id
}

resource "aws_api_gateway_integration" "play_track" {
  rest_api_id             = module.api_gateway.id
  resource_id             = aws_api_gateway_resource.play.id
  http_method             = aws_api_gateway_method.play_track.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.api_lambdas["api_start_stream"].invoke_arn
}

# ---------------------------------------------------------
# GET /tracks/{trackId}/stats
# ---------------------------------------------------------

resource "aws_api_gateway_method" "get_track_stats" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.track_stats.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = module.api_gateway.authorizer_id
}

resource "aws_api_gateway_integration" "get_track_stats" {
  rest_api_id             = module.api_gateway.id
  resource_id             = aws_api_gateway_resource.track_stats.id
  http_method             = aws_api_gateway_method.get_track_stats.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.api_lambdas["api_get_track_stats"].invoke_arn
}

# =========================================================
# ME
# =========================================================

resource "aws_api_gateway_resource" "me" {
  rest_api_id = module.api_gateway.id
  parent_id   = module.api_gateway.root_resource_id
  path_part   = "me"
}

resource "aws_api_gateway_resource" "me_listening" {
  rest_api_id = module.api_gateway.id
  parent_id   = aws_api_gateway_resource.me.id
  path_part   = "listening"
}

resource "aws_api_gateway_resource" "me_listening_history" {
  rest_api_id = module.api_gateway.id
  parent_id   = aws_api_gateway_resource.me_listening.id
  path_part   = "history"
}


resource "aws_api_gateway_resource" "me_recently_played" {
  rest_api_id = module.api_gateway.id
  parent_id   = aws_api_gateway_resource.me.id
  path_part   = "recently-played"
}

# ---------------------------------------------------------
# GET /me
# ---------------------------------------------------------

resource "aws_api_gateway_method" "get_me" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.me.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = module.api_gateway.authorizer_id
}

resource "aws_api_gateway_integration" "get_me" {
  rest_api_id             = module.api_gateway.id
  resource_id             = aws_api_gateway_resource.me.id
  http_method             = aws_api_gateway_method.get_me.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.api_lambdas["api_get_me"].invoke_arn
}



# ---------------------------------------------------------
# GET /me/recently-played
# ---------------------------------------------------------

resource "aws_api_gateway_method" "get_me_recently_played" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.me_recently_played.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = module.api_gateway.authorizer_id
}



resource "aws_api_gateway_integration" "get_me_recently_played" {
  rest_api_id             = module.api_gateway.id
  resource_id             = aws_api_gateway_resource.me_recently_played.id
  http_method             = aws_api_gateway_method.get_me_recently_played.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.api_lambdas["api_get_me_recently_played"].invoke_arn
}

# ---------------------------------------------------------
# GET /me/listening/history
# ---------------------------------------------------------

resource "aws_api_gateway_method" "get_me_listening_history" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.me_listening_history.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = module.api_gateway.authorizer_id
}

resource "aws_api_gateway_integration" "get_me_listening_history" {
  rest_api_id             = module.api_gateway.id
  resource_id             = aws_api_gateway_resource.me_listening_history.id
  http_method             = aws_api_gateway_method.get_me_listening_history.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.api_lambdas["api_get_myhistory"].invoke_arn
}

# =========================================================
# ANALYTICS
# =========================================================

resource "aws_api_gateway_resource" "analytics" {
  rest_api_id = module.api_gateway.id
  parent_id   = module.api_gateway.root_resource_id
  path_part   = "analytics"
}

resource "aws_api_gateway_resource" "analytics_global" {
  rest_api_id = module.api_gateway.id
  parent_id   = aws_api_gateway_resource.analytics.id
  path_part   = "global"
}

resource "aws_api_gateway_method" "get_analytics" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.analytics_global.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_analytics" {
  rest_api_id             = module.api_gateway.id
  resource_id             = aws_api_gateway_resource.analytics_global.id
  http_method             = aws_api_gateway_method.get_analytics.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.api_lambdas["api_get_analytics"].invoke_arn
}

# =========================================================
# SEARCH
# =========================================================

resource "aws_api_gateway_resource" "search" {
  rest_api_id = module.api_gateway.id
  parent_id   = module.api_gateway.root_resource_id
  path_part   = "search"
}

resource "aws_api_gateway_method" "search" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.search.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "search" {
  rest_api_id             = module.api_gateway.id
  resource_id             = aws_api_gateway_resource.search.id
  http_method             = aws_api_gateway_method.search.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.api_lambdas["api_search"].invoke_arn
}

# =========================================================
# HEALTH
# =========================================================

resource "aws_api_gateway_resource" "health" {
  rest_api_id = module.api_gateway.id
  parent_id   = module.api_gateway.root_resource_id
  path_part   = "health"
}

resource "aws_api_gateway_method" "health_get" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "health_get" {
  rest_api_id             = module.api_gateway.id
  resource_id             = aws_api_gateway_resource.health.id
  http_method             = aws_api_gateway_method.health_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.api_lambdas["api_healthcheck"].invoke_arn
}

# =========================================================
# CORS - OPTIONS METHODS
# =========================================================

# ---------------------------------------------------------
# OPTIONS /tracks
# ---------------------------------------------------------

resource "aws_api_gateway_method" "options_tracks" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.tracks.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_tracks" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.tracks.id
  http_method = aws_api_gateway_method.options_tracks.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_tracks_200" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.tracks.id
  http_method = aws_api_gateway_method.options_tracks.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_tracks_200" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.tracks.id
  http_method = aws_api_gateway_method.options_tracks.http_method
  status_code = aws_api_gateway_method_response.options_tracks_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }

  response_templates = {
    "application/json" = ""
  }
}

# ---------------------------------------------------------
# OPTIONS /me/recently-played
# ---------------------------------------------------------

resource "aws_api_gateway_method" "options_recently_played" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.me_recently_played.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_recently_played" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.me_recently_played.id
  http_method = aws_api_gateway_method.options_recently_played.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_recently_played_200" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.me_recently_played.id
  http_method = aws_api_gateway_method.options_recently_played.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_recently_played_200" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.me_recently_played.id
  http_method = aws_api_gateway_method.options_recently_played.http_method
  status_code = aws_api_gateway_method_response.options_recently_played_200.status_code

  depends_on = [
    aws_api_gateway_integration.options_recently_played
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }

  response_templates = {
    "application/json" = ""
  }
}



# ---------------------------------------------------------
# OPTIONS /tracks/{trackId}
# ---------------------------------------------------------

resource "aws_api_gateway_method" "options_track_id" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.track_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_track_id" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.track_id.id
  http_method = aws_api_gateway_method.options_track_id.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_track_id_200" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.track_id.id
  http_method = aws_api_gateway_method.options_track_id.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_track_id_200" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.track_id.id
  http_method = aws_api_gateway_method.options_track_id.http_method
  status_code = aws_api_gateway_method_response.options_track_id_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }

  response_templates = {
    "application/json" = ""
  }
}

# ---------------------------------------------------------
# OPTIONS /tracks/{trackId}/play
# ---------------------------------------------------------

resource "aws_api_gateway_method" "options_play" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.play.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_play" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.play.id
  http_method = aws_api_gateway_method.options_play.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_play_200" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.play.id
  http_method = aws_api_gateway_method.options_play.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_play_200" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.play.id
  http_method = aws_api_gateway_method.options_play.http_method
  status_code = aws_api_gateway_method_response.options_play_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }

  response_templates = {
    "application/json" = ""
  }
}

# ---------------------------------------------------------
# OPTIONS /tracks/{trackId}/stats
# ---------------------------------------------------------

resource "aws_api_gateway_method" "options_track_stats" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.track_stats.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_track_stats" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.track_stats.id
  http_method = aws_api_gateway_method.options_track_stats.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_track_stats_200" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.track_stats.id
  http_method = aws_api_gateway_method.options_track_stats.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_track_stats_200" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.track_stats.id
  http_method = aws_api_gateway_method.options_track_stats.http_method
  status_code = aws_api_gateway_method_response.options_track_stats_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }

  response_templates = {
    "application/json" = ""
  }
}

# ---------------------------------------------------------
# OPTIONS /me
# ---------------------------------------------------------

resource "aws_api_gateway_method" "options_me" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.me.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_me" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.me.id
  http_method = aws_api_gateway_method.options_me.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_me_200" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.me.id
  http_method = aws_api_gateway_method.options_me.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_me_200" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.me.id
  http_method = aws_api_gateway_method.options_me.http_method
  status_code = aws_api_gateway_method_response.options_me_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }

  response_templates = {
    "application/json" = ""
  }
}

# ---------------------------------------------------------
# OPTIONS /me/listening/history
# ---------------------------------------------------------

resource "aws_api_gateway_method" "options_me_listening_history" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.me_listening_history.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_me_listening_history" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.me_listening_history.id
  http_method = aws_api_gateway_method.options_me_listening_history.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_me_listening_history_200" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.me_listening_history.id
  http_method = aws_api_gateway_method.options_me_listening_history.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_me_listening_history_200" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.me_listening_history.id
  http_method = aws_api_gateway_method.options_me_listening_history.http_method
  status_code = aws_api_gateway_method_response.options_me_listening_history_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }

  response_templates = {
    "application/json" = ""
  }
}

# ---------------------------------------------------------
# OPTIONS /analytics/global
# ---------------------------------------------------------

resource "aws_api_gateway_method" "options_analytics_global" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.analytics_global.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_analytics_global" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.analytics_global.id
  http_method = aws_api_gateway_method.options_analytics_global.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_analytics_global_200" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.analytics_global.id
  http_method = aws_api_gateway_method.options_analytics_global.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }


  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_analytics_global_200" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.analytics_global.id
  http_method = aws_api_gateway_method.options_analytics_global.http_method
  status_code = aws_api_gateway_method_response.options_analytics_global_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }

  response_templates = {
    "application/json" = ""
  }
}

# ---------------------------------------------------------
# OPTIONS /search
# ---------------------------------------------------------

resource "aws_api_gateway_method" "options_search" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.search.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_search" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.search.id
  http_method = aws_api_gateway_method.options_search.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_search_200" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.search.id
  http_method = aws_api_gateway_method.options_search.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_search_200" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.search.id
  http_method = aws_api_gateway_method.options_search.http_method
  status_code = aws_api_gateway_method_response.options_search_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }

  response_templates = {
    "application/json" = ""
  }
}

# ---------------------------------------------------------
# OPTIONS /health
# ---------------------------------------------------------

resource "aws_api_gateway_method" "options_health" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_health" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.options_health.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_health_200" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.options_health.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_health_200" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.options_health.http_method
  status_code = aws_api_gateway_method_response.options_health_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }

  response_templates = {
    "application/json" = ""
  }
}

# =========================================================
# API GATEWAY - GLOBAL CORS ERROR RESPONSES
# =========================================================

resource "aws_api_gateway_gateway_response" "default_4xx" {
  rest_api_id   = module.api_gateway.id
  response_type = "DEFAULT_4XX"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
  }

  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }
}

resource "aws_api_gateway_gateway_response" "default_5xx" {
  rest_api_id   = module.api_gateway.id
  response_type = "DEFAULT_5XX"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
  }

  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }
}

# =========================================================
# DEPLOYMENT
# =========================================================

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = module.api_gateway.id

  depends_on = [
    aws_api_gateway_integration.play_track,
    aws_api_gateway_integration.get_me,
    aws_api_gateway_integration.get_me_recently_played,
    aws_api_gateway_integration.get_analytics,
    aws_api_gateway_integration.get_track,
    aws_api_gateway_integration.get_tracks,
    aws_api_gateway_integration.post_track,
    aws_api_gateway_integration.search,
    aws_api_gateway_integration.health_get,
    aws_api_gateway_integration.get_me_listening_history,
    aws_api_gateway_integration.get_track_stats,

    aws_api_gateway_integration.options_tracks,
    aws_api_gateway_integration.options_track_id,
    aws_api_gateway_integration.options_play,
    aws_api_gateway_integration.options_track_stats,
    aws_api_gateway_integration.options_me,
    aws_api_gateway_integration.options_recently_played,

    aws_api_gateway_integration.options_me_listening_history,
    aws_api_gateway_integration.options_analytics_global,
    aws_api_gateway_integration.options_search,
    aws_api_gateway_integration.options_health,

    aws_api_gateway_gateway_response.default_4xx,
    aws_api_gateway_gateway_response.default_5xx
  ]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.tracks.id,
      aws_api_gateway_resource.track_id.id,
      aws_api_gateway_resource.play.id,
      aws_api_gateway_resource.track_stats.id,
      aws_api_gateway_resource.me.id,
      aws_api_gateway_resource.me_listening.id,
      aws_api_gateway_resource.me_listening_history.id,
      aws_api_gateway_resource.analytics.id,
      aws_api_gateway_resource.analytics_global.id,
      aws_api_gateway_resource.search.id,
      aws_api_gateway_resource.health.id,
      aws_api_gateway_resource.me_recently_played.id,


      aws_api_gateway_method.post_track.id,
      aws_api_gateway_method.get_tracks.id,
      aws_api_gateway_method.get_track.id,
      aws_api_gateway_method.play_track.id,
      aws_api_gateway_method.get_track_stats.id,
      aws_api_gateway_method.get_me.id,
      aws_api_gateway_method.get_me_recently_played.id,
      aws_api_gateway_method.get_me_listening_history.id,
      aws_api_gateway_method.get_analytics.id,
      aws_api_gateway_method.search.id,
      aws_api_gateway_method.health_get.id,

      aws_api_gateway_method.options_tracks.id,
      aws_api_gateway_method.options_track_id.id,
      aws_api_gateway_method.options_play.id,
      aws_api_gateway_method.options_track_stats.id,
      aws_api_gateway_method.options_me.id,
      aws_api_gateway_method.options_recently_played.id,

      aws_api_gateway_method.options_me_listening_history.id,
      aws_api_gateway_method.options_analytics_global.id,
      aws_api_gateway_method.options_search.id,
      aws_api_gateway_method.options_health.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# =========================================================
# STAGE
# =========================================================

resource "aws_api_gateway_stage" "dev" {
  stage_name    = "dev"
  rest_api_id   = module.api_gateway.id
  deployment_id = aws_api_gateway_deployment.this.id

  xray_tracing_enabled = true

  access_log_settings {
    destination_arn = module.monitoring_api.api_gateway_access_log_group_arn

    format = jsonencode({
      requestId           = "$context.requestId"
      extendedRequestId   = "$context.extendedRequestId"
      ip                  = "$context.identity.sourceIp"
      caller              = "$context.identity.caller"
      user                = "$context.identity.user"
      requestTime         = "$context.requestTime"
      httpMethod          = "$context.httpMethod"
      resourcePath        = "$context.resourcePath"
      status              = "$context.status"
      protocol            = "$context.protocol"
      responseLength      = "$context.responseLength"
      responseLatency     = "$context.responseLatency"
      integrationLatency  = "$context.integration.latency"
      errorMessage        = "$context.error.message"
      errorResponseType   = "$context.error.responseType"
      authorizerPrincipal = "$context.authorizer.principalId"
      userAgent           = "$context.identity.userAgent"
    })
  }

  tags = {
    Environment = "dev"
    Project     = "spotify-app"
  }

  depends_on = [
    module.monitoring_api
  ]
}





# Custom domain pour l'api 

resource "aws_api_gateway_domain_name" "api" {
  domain_name              = var.api_domain_name
  regional_certificate_arn = aws_acm_certificate_validation.api.certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Environment = "dev"
    Project     = "spotify-app"
    Component   = "api-custom-domain"
  }
}

resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = module.api_gateway.id
  stage_name  = aws_api_gateway_stage.dev.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name
}