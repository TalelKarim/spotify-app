locals {
  orchestration_lambda_arns = [
    for _, m in module.orchestration_lambdas : m.lambda_arn
  ]
}

module "iam" {
  source = "../../modules/iam"

  project_name  = var.project_name
  sqs_queue_arn = module.listening_events_queue.queue_arn
  orchestration_lambda_arns = local.orchestration_lambda_arns

}
