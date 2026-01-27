locals {
  orchestration_lambdas = {
    orchestrator_daily_analytics = {
      role = module.iam.lambda_step_functions_role_arn
      env  = {}
    }

    orchestrator_recommendations = {
      role = module.iam.lambda_step_functions_role_arn
      env  = {}
    }
  }
}

module "orchestration_lambdas" {
  source   = "../../../modules/lambda"
  for_each = local.orchestration_lambdas

  function_name = "spotify-dev-${each.key}"
  role_arn      = each.value.role
  handler       = "handler.main"
  package_path  = "../../../app/lambdas/${each.key}.zip"

  environment_variables = each.value.env
}
