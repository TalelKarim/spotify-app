output "lambda_api_role_arn" {
  value = aws_iam_role.lambda_api.arn
}

output "lambda_events_role_arn" {
  value = aws_iam_role.lambda_events.arn
}

output "lambda_step_functions_role_arn" {
  value = aws_iam_role.lambda_step_functions.arn
}

output "eventbridge_stepfn_role_arn" {
  value = aws_iam_role.eventbridge_stepfn.arn
}
