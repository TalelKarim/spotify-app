module "eventbridge" {
  source = "../../modules/eventbridge"

  bus_name  = "spotify-dev-bus"
  rule_name = "spotify-dev-track-played"

  event_pattern = jsonencode({
    source = ["spotify.api"]
    detail-type = ["TrackPlayed"]
  })
}
