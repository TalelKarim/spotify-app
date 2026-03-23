data "aws_caller_identity" "current" {}

locals {
  frontend_cf_requests_metrics = [
    ["AWS/CloudFront", "Requests", "DistributionId", var.frontend_distribution_id, "Region", "Global", { "label" : "frontend requests", "stat" : "Sum" }],
    ["AWS/CloudFront", "BytesDownloaded", "DistributionId", var.frontend_distribution_id, "Region", "Global", { "label" : "frontend bytes", "stat" : "Sum", "yAxis" : "right" }]
  ]

  frontend_cf_error_metrics = [
    ["AWS/CloudFront", "4xxErrorRate", "DistributionId", var.frontend_distribution_id, "Region", "Global", { "label" : "frontend 4xx %", "stat" : "Average" }],
    ["AWS/CloudFront", "5xxErrorRate", "DistributionId", var.frontend_distribution_id, "Region", "Global", { "label" : "frontend 5xx %", "stat" : "Average" }],
    ["AWS/CloudFront", "TotalErrorRate", "DistributionId", var.frontend_distribution_id, "Region", "Global", { "label" : "frontend total error %", "stat" : "Average" }]
  ]

  media_cf_requests_metrics = [
    ["AWS/CloudFront", "Requests", "DistributionId", var.media_distribution_id, "Region", "Global", { "label" : "media requests", "stat" : "Sum" }],
    ["AWS/CloudFront", "BytesDownloaded", "DistributionId", var.media_distribution_id, "Region", "Global", { "label" : "media bytes", "stat" : "Sum", "yAxis" : "right" }]
  ]

  media_cf_error_metrics = [
    ["AWS/CloudFront", "4xxErrorRate", "DistributionId", var.media_distribution_id, "Region", "Global", { "label" : "media 4xx %", "stat" : "Average" }],
    ["AWS/CloudFront", "5xxErrorRate", "DistributionId", var.media_distribution_id, "Region", "Global", { "label" : "media 5xx %", "stat" : "Average" }],
    ["AWS/CloudFront", "TotalErrorRate", "DistributionId", var.media_distribution_id, "Region", "Global", { "label" : "media total error %", "stat" : "Average" }]
  ]

  cloudfront_extended_widgets = var.enable_cloudfront_additional_metrics ? [
    {
      type   = "metric"
      x      = 0
      y      = 12
      width  = 12
      height = 6
      properties = {
        title  = "CloudFront Frontend - Cache Hit / Origin Latency"
        region = "us-east-1"
        view   = "timeSeries"
        metrics = [
          ["AWS/CloudFront", "CacheHitRate", "DistributionId", var.frontend_distribution_id, "Region", "Global", { "label" : "frontend cache hit %", "stat" : "Average" }],
          ["AWS/CloudFront", "OriginLatency", "DistributionId", var.frontend_distribution_id, "Region", "Global", { "label" : "frontend origin p95", "stat" : "p95", "yAxis" : "right" }]
        ]
      }
    },
    {
      type   = "metric"
      x      = 12
      y      = 12
      width  = 12
      height = 6
      properties = {
        title  = "CloudFront Media - Cache Hit / Origin Latency"
        region = "us-east-1"
        view   = "timeSeries"
        metrics = [
          ["AWS/CloudFront", "CacheHitRate", "DistributionId", var.media_distribution_id, "Region", "Global", { "label" : "media cache hit %", "stat" : "Average" }],
          ["AWS/CloudFront", "OriginLatency", "DistributionId", var.media_distribution_id, "Region", "Global", { "label" : "media origin p95", "stat" : "p95", "yAxis" : "right" }]
        ]
      }
    }
  ] : []

  cloudfront_function_widgets = var.cloudfront_function_name == null ? [] : [
    {
      type   = "metric"
      x      = 0
      y      = 18
      width  = 24
      height = 6
      properties = {
        title  = "CloudFront Function - SPA Rewrite Health"
        region = "us-east-1"
        view   = "timeSeries"
        metrics = [
          ["AWS/CloudFront", "FunctionInvocations", "FunctionName", var.cloudfront_function_name, "Region", "Global", { "label" : "invocations", "stat" : "Sum" }],
          ["AWS/CloudFront", "FunctionExecutionErrors", "FunctionName", var.cloudfront_function_name, "Region", "Global", { "label" : "execution errors", "stat" : "Sum" }],
          ["AWS/CloudFront", "FunctionValidationErrors", "FunctionName", var.cloudfront_function_name, "Region", "Global", { "label" : "validation errors", "stat" : "Sum" }],
          ["AWS/CloudFront", "FunctionThrottles", "FunctionName", var.cloudfront_function_name, "Region", "Global", { "label" : "throttles", "stat" : "Sum" }]
        ]
      }
    }
  ]
  eventbridge_delivery_metrics = concat(
    [
      for rule in var.eventbridge_rule_names :
      ["AWS/Events", "InvocationAttempts", "EventBusName", var.event_bus_name, "RuleName", rule]
    ],
    [
      for rule in var.eventbridge_rule_names :
      ["AWS/Events", "SuccessfulInvocationAttempts", "EventBusName", var.event_bus_name, "RuleName", rule]
    ],
    [
      for rule in var.eventbridge_rule_names :
      ["AWS/Events", "FailedInvocations", "EventBusName", var.event_bus_name, "RuleName", rule]
    ]
  )

  eventbridge_latency_metrics = [
    for rule in var.eventbridge_rule_names :
    ["AWS/Events", "IngestionToInvocationSuccessLatency", "EventBusName", var.event_bus_name, "RuleName", rule]
  ]

  opensearch_cluster_status_metrics = [
    ["AWS/ES", "ClusterStatus.green", "DomainName", var.opensearch_domain_name, "ClientId", data.aws_caller_identity.current.account_id, { "label" : "green", "stat" : "Maximum" }],
    ["AWS/ES", "ClusterStatus.yellow", "DomainName", var.opensearch_domain_name, "ClientId", data.aws_caller_identity.current.account_id, { "label" : "yellow", "stat" : "Maximum" }],
    ["AWS/ES", "ClusterStatus.red", "DomainName", var.opensearch_domain_name, "ClientId", data.aws_caller_identity.current.account_id, { "label" : "red", "stat" : "Maximum" }]
  ]

  opensearch_resource_metrics = [
    ["AWS/ES", "CPUUtilization", "DomainName", var.opensearch_domain_name, "ClientId", data.aws_caller_identity.current.account_id, { "label" : "cpu %", "stat" : "Maximum" }],
    ["AWS/ES", "JVMMemoryPressure", "DomainName", var.opensearch_domain_name, "ClientId", data.aws_caller_identity.current.account_id, { "label" : "jvm %", "stat" : "Maximum" }]
  ]

  opensearch_storage_metrics = [
    ["AWS/ES", "FreeStorageSpace", "DomainName", var.opensearch_domain_name, "ClientId", data.aws_caller_identity.current.account_id, { "label" : "free storage MiB", "stat" : "Minimum" }],
    ["AWS/ES", "ClusterIndexWritesBlocked", "DomainName", var.opensearch_domain_name, "ClientId", data.aws_caller_identity.current.account_id, { "label" : "writes blocked", "stat" : "Maximum" }],
    ["AWS/ES", "AutomatedSnapshotFailure", "DomainName", var.opensearch_domain_name, "ClientId", data.aws_caller_identity.current.account_id, { "label" : "snapshot failure", "stat" : "Maximum" }]
  ]
}

resource "aws_cloudwatch_dashboard" "edge_access" {
  dashboard_name = "${var.project}-${var.env}-edge-access"

  dashboard_body = jsonencode({
    widgets = concat(
      [
        {
          type   = "metric"
          x      = 0
          y      = 0
          width  = 12
          height = 6
          properties = {
            title   = "CloudFront Frontend - Requests / Bytes"
            region  = "us-east-1"
            view    = "timeSeries"
            metrics = local.frontend_cf_requests_metrics
          }
        },
        {
          type   = "metric"
          x      = 12
          y      = 0
          width  = 12
          height = 6
          properties = {
            title   = "CloudFront Frontend - Error Rates"
            region  = "us-east-1"
            view    = "timeSeries"
            metrics = local.frontend_cf_error_metrics
          }
        },
        {
          type   = "metric"
          x      = 0
          y      = 6
          width  = 12
          height = 6
          properties = {
            title   = "CloudFront Media - Requests / Bytes"
            region  = "us-east-1"
            view    = "timeSeries"
            metrics = local.media_cf_requests_metrics
          }
        },
        {
          type   = "metric"
          x      = 12
          y      = 6
          width  = 12
          height = 6
          properties = {
            title   = "CloudFront Media - Error Rates"
            region  = "us-east-1"
            view    = "timeSeries"
            metrics = local.media_cf_error_metrics
          }
        }
      ],
      local.cloudfront_extended_widgets,
      local.cloudfront_function_widgets
    )
  })
}

resource "aws_cloudwatch_dashboard" "async_search" {
  dashboard_name = "${var.project}-${var.env}-async-search"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Step Functions - Executions"
          region = var.region
          view   = "timeSeries"
          metrics = [
            ["AWS/States", "ExecutionsStarted", "StateMachineArn", var.state_machine_arn, { "label" : "started", "stat" : "Sum" }],
            ["AWS/States", "ExecutionsSucceeded", "StateMachineArn", var.state_machine_arn, { "label" : "succeeded", "stat" : "Sum" }],
            ["AWS/States", "ExecutionsFailed", "StateMachineArn", var.state_machine_arn, { "label" : "failed", "stat" : "Sum" }],
            ["AWS/States", "ExecutionsTimedOut", "StateMachineArn", var.state_machine_arn, { "label" : "timed out", "stat" : "Sum" }],
            ["AWS/States", "ExecutionThrottled", "StateMachineArn", var.state_machine_arn, { "label" : "throttled", "stat" : "Sum" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Step Functions - Execution Time"
          region = var.region
          view   = "timeSeries"
          metrics = [
            ["AWS/States", "ExecutionTime", "StateMachineArn", var.state_machine_arn, { "label" : "execution time avg ms", "stat" : "Average" }],
            ["AWS/States", "OpenExecutionCount", { "label" : "open executions", "stat" : "Maximum", "yAxis" : "right" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title   = "EventBridge - Delivery"
          region  = var.region
          view    = "timeSeries"
          metrics = local.eventbridge_delivery_metrics
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title   = "EventBridge - Success Latency"
          region  = var.region
          view    = "timeSeries"
          metrics = local.eventbridge_latency_metrics
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 8
        height = 6
        properties = {
          title   = "OpenSearch - Cluster Status"
          region  = var.region
          view    = "timeSeries"
          metrics = local.opensearch_cluster_status_metrics
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 12
        width  = 8
        height = 6
        properties = {
          title   = "OpenSearch - CPU / JVM"
          region  = var.region
          view    = "timeSeries"
          metrics = local.opensearch_resource_metrics
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 12
        width  = 8
        height = 6
        properties = {
          title   = "OpenSearch - Storage / Write Block / Snapshot"
          region  = var.region
          view    = "timeSeries"
          metrics = local.opensearch_storage_metrics
        }
      }
    ]
  })
}