module "listening_analytics" {
  source = "../../modules/step-functions"

  name     = "spotify-dev-listening-analytics"
  role_arn = module.iam.lambda_step_functions_role_arn

  definition = jsonencode({
    StartAt = "UpdateTrackStats"
    States = {
      UpdateTrackStats = {
        Type     = "Task"
        Resource = module.orchestration_lambdas["orch_update_track_stats"].lambda_arn
        Next     = "UpdateUserStats"
      }

      UpdateUserStats = {
        Type     = "Task"
        Resource = module.orchestration_lambdas["orch_update_user_stats"].lambda_arn
        Next     = "ComputeAnalytics"
      }

      ComputeAnalytics = {
        Type     = "Task"
        Resource = module.orchestration_lambdas["orch_compute_analytics"].lambda_arn
        End      = true
      }
    }
  })
}
