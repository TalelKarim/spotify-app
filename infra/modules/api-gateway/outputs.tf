output "id" {
  value = aws_api_gateway_rest_api.this.id
}

output "root_resource_id" {
  value = aws_api_gateway_rest_api.this.root_resource_id
}

output "execution_arn" {
  value = aws_api_gateway_rest_api.this.execution_arn
}

output "authorizer_id" {
  value = aws_api_gateway_authorizer.cognito.id
}