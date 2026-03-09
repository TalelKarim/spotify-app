# -------------------------------------------------
# CORS helpers - Gateway Responses
# -------------------------------------------------

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


# -------------------------------------------------
# CORS - OPTIONS /tracks
# -------------------------------------------------

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



# -------------------------------------------------
# CORS - OPTIONS /tracks/{trackId}
# -------------------------------------------------

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




# -------------------------------------------------
# CORS - OPTIONS /tracks/{trackId}/play
# -------------------------------------------------

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



# -------------------------------------------------
# CORS - OPTIONS /tracks/{trackId}/stats
# -------------------------------------------------

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




# -------------------------------------------------
# CORS - OPTIONS /me
# -------------------------------------------------

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



# -------------------------------------------------
# CORS - OPTIONS /me/listening/history
# -------------------------------------------------

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


# -------------------------------------------------
# CORS - OPTIONS /analytics/global
# -------------------------------------------------

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


# -------------------------------------------------
# CORS - OPTIONS /search
# -------------------------------------------------

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




# -------------------------------------------------
# CORS - OPTIONS /health
# -------------------------------------------------

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




# Api Gateway Deployment
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = module.api_gateway.id

  depends_on = [
    aws_api_gateway_integration.play_track,
    aws_api_gateway_integration.get_me,
    aws_api_gateway_integration.get_analytics,
    aws_api_gateway_integration.get_track,
    aws_api_gateway_integration.get_tracks,
    aws_api_gateway_integration.post_track,
    aws_api_gateway_integration.search,
    aws_api_gateway_integration.health_get,
    aws_api_gateway_integration.get_me_listening_history,

    aws_api_gateway_integration.options_tracks,
    aws_api_gateway_integration.options_track_id,
    aws_api_gateway_integration.options_play,
    aws_api_gateway_integration.options_track_stats,
    aws_api_gateway_integration.options_me,
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
      aws_api_gateway_resource.search.id,
      aws_api_gateway_resource.analytics.id,
      aws_api_gateway_resource.analytics_global.id,
      aws_api_gateway_resource.health.id,

      aws_api_gateway_method.options_tracks.id,
      aws_api_gateway_method.options_track_id.id,
      aws_api_gateway_method.options_play.id,
      aws_api_gateway_method.options_track_stats.id,
      aws_api_gateway_method.options_me.id,
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



