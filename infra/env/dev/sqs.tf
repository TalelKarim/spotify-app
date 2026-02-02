module "listening_events_queue" {
  source = "../../modules/sqs"

  queue_name = "spotify-dev-listening-events"
  allow_eventbridge = true
}
