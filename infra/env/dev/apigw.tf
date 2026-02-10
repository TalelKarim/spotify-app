module "api_gateway" {
  source = "../../modules/api-gateway"
  name   = "spotify-dev-api"
}



# tracks

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

# POST /tracks/{trackId}/play
resource "aws_api_gateway_method" "play_track" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.play.id
  http_method   = "POST"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "play_track" {
  rest_api_id             = module.api_gateway.id
  resource_id             = aws_api_gateway_resource.play.id
  http_method             = aws_api_gateway_method.play_track.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.api_lambdas["api_start_stream"].invoke_arn
}


# GET /tracks/{trackId}

resource "aws_api_gateway_method" "get_track" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.track_id.id
  http_method   = "GET"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "get_track" {
  rest_api_id = module.api_gateway.id
  resource_id = aws_api_gateway_resource.track_id.id
  http_method = aws_api_gateway_method.get_track.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.api_lambdas["api_get_track"].invoke_arn
}



# GET /users/{userId}


resource "aws_api_gateway_resource" "users" {
  rest_api_id = module.api_gateway.id
  parent_id   = module.api_gateway.root_resource_id
  path_part   = "users"
}

resource "aws_api_gateway_resource" "user_id" {
  rest_api_id = module.api_gateway.id
  parent_id   = aws_api_gateway_resource.users.id
  path_part   = "{userId}"
}


resource "aws_api_gateway_method" "get_user" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.user_id.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_user" {
  rest_api_id             = module.api_gateway.id
  resource_id             = aws_api_gateway_resource.user_id.id
  http_method             = aws_api_gateway_method.get_user.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.api_lambdas["api_get_user"].invoke_arn
}



# GET /search


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

# POST /events/listening

resource "aws_api_gateway_resource" "events" {
  rest_api_id = module.api_gateway.id
  parent_id   = module.api_gateway.root_resource_id
  path_part   = "events"
}

resource "aws_api_gateway_resource" "listening" {
  rest_api_id = module.api_gateway.id
  parent_id   = aws_api_gateway_resource.events.id
  path_part   = "listening"
}

resource "aws_api_gateway_method" "post_listening_event" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.listening.id
  http_method   = "POST"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "post_listening_event" {
  rest_api_id             = module.api_gateway.id
  resource_id             = aws_api_gateway_resource.listening.id
  http_method             = aws_api_gateway_method.post_listening_event.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.api_lambdas["api_post_listening_event"].invoke_arn
}




# Api Gateway Deployment
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = module.api_gateway.id

  # ⚠️ TRÈS IMPORTANT
  depends_on = [
    aws_api_gateway_integration.play_track,
    aws_api_gateway_integration.get_track,
    aws_api_gateway_integration.get_user,
    aws_api_gateway_integration.search,
    aws_api_gateway_integration.post_listening_event
  ]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.tracks.id,
      aws_api_gateway_resource.users.id,
      aws_api_gateway_resource.search.id,
      aws_api_gateway_resource.events.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}



# Stage Dev api gw 
resource "aws_api_gateway_stage" "dev" {
  stage_name    = "dev"
  rest_api_id   = module.api_gateway.id
  deployment_id = aws_api_gateway_deployment.this.id

  xray_tracing_enabled = true

  tags = {
    Environment = "dev"
    Project     = "spotify-app"
  }
}


















