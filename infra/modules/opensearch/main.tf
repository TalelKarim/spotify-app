data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


resource "aws_iam_service_linked_role" "opensearch" {
  aws_service_name = "es.amazonaws.com"
  description      = "Service-linked role for Amazon OpenSearch Service"

  lifecycle {
    ignore_changes = [description]
  }
}

resource "aws_security_group" "opensearch" {
  name        = "${var.domain_name}-sg"
  description = "Security group for OpenSearch domain ${var.domain_name}"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.domain_name}-sg"
  })
}

resource "aws_cloudwatch_log_group" "index_slow" {
  name              = "/aws/opensearch/${var.domain_name}/index-slow-logs"
  retention_in_days = 14

  tags = merge(var.tags, {
    Name = "/aws/opensearch/${var.domain_name}/index-slow-logs"
  })
}

resource "aws_opensearch_domain" "this" {
  depends_on = [aws_iam_service_linked_role.opensearch]

  domain_name    = var.domain_name
  engine_version = var.engine_version

  cluster_config {
    instance_type  = var.instance_type
    instance_count = var.instance_count

    # On part du principe qu’on a au moins 2 subnets (2 AZ)
    zone_awareness_enabled = false

    # zone_awareness_config {
    #   availability_zone_count = 2
    # }
  }

  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.opensearch.id]
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp3"
    volume_size = var.ebs_volume_size
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  log_publishing_options {
    log_type                 = "INDEX_SLOW_LOGS"
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.index_slow.arn
    enabled                  = true
  }

  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "es:*"
        Resource = "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*"
      }
    ]
  })

  tags = merge(var.tags, {
    Domain = var.domain_name
  })
}
