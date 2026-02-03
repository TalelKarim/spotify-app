module "eventbridge_bus" {
  source   = "../../modules/eventbridge_bus"
  bus_name = "spotify-dev-bus"
}

module "rule_track_played_to_sqs" {
  source = "../../modules/eventbridge_rule"

  bus_name  = module.eventbridge_bus.bus_name
  rule_name = "spotify-dev-track-played-to-sqs"

  event_pattern = jsonencode({
    source      = ["spotify.api"]
    detail-type = ["TrackPlayed"]
  })
}


module "rule_track_played_to_stepfn" {
  source = "../../modules/eventbridge_rule"

  bus_name  = module.eventbridge_bus.bus_name
  rule_name = "spotify-dev-track-played-to-stepfn"

  event_pattern = jsonencode({
    source      = ["spotify.api"]
    detail-type = ["TrackPlayed"]
  })
}
