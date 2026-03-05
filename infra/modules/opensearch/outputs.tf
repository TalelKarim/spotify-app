output "domain_arn" {
  description = "ARN du domaine OpenSearch"
  value       = aws_opensearch_domain.this.arn
}

output "domain_endpoint" {
  description = "Endpoint HTTPS du domaine OpenSearch"
  value       = aws_opensearch_domain.this.endpoint
}


