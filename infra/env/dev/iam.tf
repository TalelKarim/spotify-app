
module "iam" {
  source = "../../modules/iam"

  project_name  = var.project_name
  sqs_queue_arn = module.listening_events_queue.queue_arn
}
