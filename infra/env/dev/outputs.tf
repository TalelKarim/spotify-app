output "lambda_api_role_arn" {
  value = module.iam.lambda_api_role_arn
}

output "lambda_events_role_arn" {
  value = module.iam.lambda_events_role_arn
}


output "lambda_step_functions_role_arn" {
  value = module.iam.lambda_step_functions_role_arn
}


output "kms_key_arn" {
  value = module.kms.kms_key_arn
}


output "apigw_invoke_url_dev" {
  value = aws_api_gateway_stage.dev.invoke_url
}


output "COGNITO_USER_POOLS" {
  value = module.cognito.user_pool_arn
}


output "opensearch_domain" {
  value = module.opensearch.domain_endpoint
}


output "cognito_idp" {
  value = module.cognito.cognito_oidc_issuer
}


output "cognito_client_id" {
  value = module.cognito.client_id
}


output "cloudfront_domain_media" {
  value = module.media.cloudfront_domain
}


output "cognito_domain" {
  value = module.cognito.cognito_domain
}