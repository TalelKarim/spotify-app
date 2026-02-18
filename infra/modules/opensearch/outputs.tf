output "domain_arn" {
  description = "ARN du domaine OpenSearch"
  value       = aws_opensearch_domain.this.arn
}

output "domain_endpoint" {
  description = "Endpoint HTTPS du domaine OpenSearch"
  value       = aws_opensearch_domain.this.endpoint
}

output "security_group_id" {
  description = "Security Group ID associé au domaine OpenSearch"
  value       = aws_security_group.opensearch.id
}
