module "listening_events_queue" {
  source = "../../modules/sqs"

  queue_name        = "spotify-dev-listening-events"
  allow_eventbridge = true
  create_dlq        = true
  max_receive_count = 5
}
