

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




# frontend outputs :

output "frontend_bucket_name" {
  value = module.frontend.bucket_name
}

output "frontend_cloudfront_distribution_id" {
  value = module.frontend.cloudfront_distribution_id
}

output "frontend_cloudfront_domain_name" {
  value = module.frontend.cloudfront_domain_name
}





#github actions 

output "github_actions_frontend_role_arn" {
  value = aws_iam_role.github_actions_frontend_deploy.arn
}