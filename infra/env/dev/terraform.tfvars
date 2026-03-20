project_name = "spotify-dev"
aws_region   = "eu-west-1"
vpc_name     = "spotify-dev-vpc"
vpc_cidr     = "10.20.0.0/16"



#github actions config 

github_owner  = "TalelKarim"
github_repo   = "spotify-app"
github_branch = "main"


frontend_origin = "https://spotify.talelkarimchebbi.com"


root_domain_name     = "talelkarimchebbi.com"
frontend_domain_name = "spotify.talelkarimchebbi.com"
api_domain_name      = "api.spotify.talelkarimchebbi.com"





# Observability

alarm_notification_email = "talelkarimc@gmail.com"

api_gateway_name = "spotify-dev-api"
api_stage_name   = "dev"

lambda_function_names = [
  "spotify-dev-api_healthcheck",
  "spotify-dev-api_get_tracks",
  "spotify-dev-api_get_track",
  "spotify-dev-api_create_track",
  "spotify-dev-api_start_stream",
  "spotify-dev-api_get_track_stats",
  "spotify-dev-api_get_me",
  "spotify-dev-api_get_myhistory",
  "spotify-dev-api_get_me_recently_played",
  "spotify-dev-api_search",
  "spotify-dev-api_get_analytics",
  "spotify-dev-process_track_upload"
]

sqs_queue_name = "spotify-dev-events"

dynamodb_table_names = [
  "spotify-dev-tracks",
  "spotify-dev-listening-events",
  "spotify-dev-analytics"
]