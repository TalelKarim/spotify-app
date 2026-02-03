module "listening_analytics" {
  source = "../../modules/step-functions"

  name     = "spotify-dev-listening-analytics"
  role_arn = module.iam.lambda_step_functions_role_arn

  definition = jsonencode({
    StartAt = "StoreEvent"
    States = {
      StoreEvent = {
        Type     = "Task"
        Resource = module.event_lambdas["event_store_listening_event"].lambda_arn
        Next     = "UpdateStats"
      }
      UpdateStats = {
        Type     = "Task"
        Resource = module.event_lambdas["event_update_track_stats"].lambda_arn
        End      = true
      }
    }
  })
}
