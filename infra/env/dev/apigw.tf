module "api_gateway" {
  source = "../../modules/api-gateway"
  name   = "spotify-dev-api"
}


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


resource "aws_api_gateway_method" "play_track" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.play.id
  http_method   = "POST"
  authorization = "NONE" # Cognito arrive juste après
}
