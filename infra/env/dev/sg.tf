resource "aws_security_group" "lambda_search" {
  name        = "spotify-${var.env}-lambda-search-sg"
  description = "Security group for search-related Lambdas (api_search + indexer)"
  vpc_id      = module.vpc.vpc_id

  # Lambda n’écoute pas -> pas d’ingress
  revoke_rules_on_delete = true

  # Les Lambdas peuvent sortir en HTTPS (443).
  # Pour l’instant on autorise tout le VPC (OpenSearch est aussi dans ce VPC).
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project     = "spotify-app"
    Environment = var.env
    Terraform   = "true"
  }
}
