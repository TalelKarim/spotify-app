data "aws_caller_identity" "current" {}
data "aws_region" "current" {}




resource "null_resource" "configure_opensearch_security" {

  depends_on = [
    aws_opensearch_domain.this
  ]

  provisioner "local-exec" {

    command = <<EOT

set -e

ENDPOINT="https://${aws_opensearch_domain.this.endpoint}"
AUTH="admin:${var.master_password}"

echo "Waiting for OpenSearch cluster..."

for i in {1..30}; do
  if curl -s -u $AUTH "$ENDPOINT/_cluster/health" > /dev/null; then
    echo "Cluster ready"
    break
  fi
  echo "Retry $i..."
  sleep 10
done

echo "Creating role tracks_api_role..."

curl -s -u $AUTH \
  -H "Content-Type: application/json" \
  -X PUT "$ENDPOINT/_plugins/_security/api/roles/tracks_api_role" \
  -d '{
    "cluster_permissions": [],
    "index_permissions": [{
      "index_patterns": ["tracks*"],
      "allowed_actions": [
              "crud"
      ]
    }]
  }'

echo "Mapping lambda role..."

curl -s -u $AUTH \
  -H "Content-Type: application/json" \
  -X PUT "$ENDPOINT/_plugins/_security/api/rolesmapping/tracks_api_role" \
  -d '{
    "backend_roles":["${var.tech_role}","${var.api_role}"]

  }'

echo "Ensuring admin mapping..."

curl -s -u $AUTH \
  -H "Content-Type: application/json" \
  -X PUT "$ENDPOINT/_plugins/_security/api/rolesmapping/all_access" \
  -d '{
    "users": ["admin"]
  }'

echo "Waiting security plugin..."

sleep 10

echo "OpenSearch security configured."

EOT
  }

  triggers = {
    endpoint =  aws_opensearch_domain.this.endpoint
  }
}



resource "aws_iam_service_linked_role" "opensearch" {
  aws_service_name = "es.amazonaws.com"
  description      = "Service-linked role for Amazon OpenSearch Service"

  lifecycle {
    ignore_changes = [description]
  }
}

resource "aws_cloudwatch_log_group" "index_slow" {
  name              = "/aws/opensearch/${var.domain_name}/index-slow-logs"
  retention_in_days = 14

  tags = merge(var.tags, {
    Name = "/aws/opensearch/${var.domain_name}/index-slow-logs"
  })
}

resource "aws_cloudwatch_log_resource_policy" "opensearch_logs" {
  policy_name = "${var.domain_name}-opensearch-logs-policy"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "OpenSearchLogsToCloudWatch"
        Effect = "Allow"
        Principal = {
          Service = "es.amazonaws.com"
        }
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.index_slow.arn}:*"
      }
    ]
  })
}

resource "aws_opensearch_domain" "this" {
  depends_on = [aws_iam_service_linked_role.opensearch]

  domain_name    = var.domain_name
  engine_version = var.engine_version

  cluster_config {
    instance_type          = var.instance_type
    instance_count         = var.instance_count
    zone_awareness_enabled = false
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp3"
    volume_size = var.ebs_volume_size
  }

  encrypt_at_rest {
    enabled = true
  }



  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true

    master_user_options {
      master_user_name     = "admin"
      master_user_password = var.master_password 
    }
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

  # 🔥 PUBLIC ACCESS POLICY (OUVERT)
  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "es:ESHttp*"
        Resource  = "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*"
      }
    ]
  })

  tags = merge(var.tags, {
    Domain = var.domain_name
  })
}