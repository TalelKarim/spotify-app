output "lambda_api_role_arn" {
  value = module.iam.lambda_api_role_arn
}

output "lambda_events_role_arn" {
  value = module.iam.lambda_events_role_arn
}


output "lambda_step_functions_role_arn" {
  value = module.iam.lambda_step_functions_role_arn
}
