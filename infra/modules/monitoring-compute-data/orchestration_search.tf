data "aws_caller_identity" "current" {}

locals {
  eventbridge_rule_dimensions = {
    for rule in var.eventbridge_rule_names : rule => {
      EventBusName = var.event_bus_name
      RuleName     = rule
    }
  }

  opensearch_dimensions = {
    DomainName = var.opensearch_domain_name
    ClientId   = data.aws_caller_identity.current.account_id
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  for_each = toset(var.lambda_function_names)

  alarm_name          = "${each.value}-throttles"
  alarm_description   = "Lambda throttles > 0 sur 5 minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  period              = 300
  statistic           = "Sum"
  namespace           = "AWS/Lambda"
  metric_name         = "Throttles"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = each.value
  }

  alarm_actions = [var.alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "dlq_visible_messages" {
  count               = var.dlq_queue_name == null ? 0 : 1
  alarm_name          = "${var.project}-${var.env}-dlq-visible-messages"
  alarm_description   = "DLQ contient au moins 1 message"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  period              = 300
  statistic           = "Maximum"
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = var.dlq_queue_name
  }

  alarm_actions = [var.alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "stepfunctions_failed" {
  alarm_name          = "${var.project}-${var.env}-stepfunctions-failed"
  alarm_description   = "Step Functions failed executions > 0"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  period              = 300
  statistic           = "Sum"
  namespace           = "AWS/States"
  metric_name         = "ExecutionsFailed"
  treat_missing_data  = "notBreaching"

  dimensions = {
    StateMachineArn = var.state_machine_arn
  }

  alarm_actions = [var.alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "stepfunctions_timed_out" {
  alarm_name          = "${var.project}-${var.env}-stepfunctions-timed-out"
  alarm_description   = "Step Functions timed out executions > 0"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  period              = 300
  statistic           = "Sum"
  namespace           = "AWS/States"
  metric_name         = "ExecutionsTimedOut"
  treat_missing_data  = "notBreaching"

  dimensions = {
    StateMachineArn = var.state_machine_arn
  }

  alarm_actions = [var.alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "stepfunctions_throttled" {
  alarm_name          = "${var.project}-${var.env}-stepfunctions-throttled"
  alarm_description   = "Step Functions execution throttled > 0"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  period              = 300
  statistic           = "Sum"
  namespace           = "AWS/States"
  metric_name         = "ExecutionThrottled"
  treat_missing_data  = "notBreaching"

  dimensions = {
    StateMachineArn = var.state_machine_arn
  }

  alarm_actions = [var.alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "eventbridge_failed_invocations" {
  for_each = local.eventbridge_rule_dimensions

  alarm_name          = "${var.project}-${var.env}-${each.key}-eventbridge-failed-invocations"
  alarm_description   = "EventBridge failed invocations > 0 pour la règle ${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  period              = 300
  statistic           = "Sum"
  namespace           = "AWS/Events"
  metric_name         = "FailedInvocations"
  treat_missing_data  = "notBreaching"
  dimensions          = each.value

  alarm_actions = [var.alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "eventbridge_dlq_send_failed" {
  for_each = local.eventbridge_rule_dimensions

  alarm_name          = "${var.project}-${var.env}-${each.key}-eventbridge-dlq-send-failed"
  alarm_description   = "EventBridge n'a pas pu envoyer en DLQ pour la règle ${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  period              = 300
  statistic           = "Sum"
  namespace           = "AWS/Events"
  metric_name         = "InvocationsFailedToBeSentToDlq"
  treat_missing_data  = "notBreaching"
  dimensions          = each.value

  alarm_actions = [var.alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "eventbridge_throttled_rules" {
  for_each = local.eventbridge_rule_dimensions

  alarm_name          = "${var.project}-${var.env}-${each.key}-eventbridge-throttled"
  alarm_description   = "EventBridge throttled rule > 0 pour ${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  period              = 300
  statistic           = "Sum"
  namespace           = "AWS/Events"
  metric_name         = "ThrottledRules"
  treat_missing_data  = "notBreaching"
  dimensions          = each.value

  alarm_actions = [var.alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "opensearch_red" {
  alarm_name          = "${var.project}-${var.env}-opensearch-cluster-red"
  alarm_description   = "OpenSearch cluster status red"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  period              = 60
  statistic           = "Maximum"
  namespace           = "AWS/ES"
  metric_name         = "ClusterStatus.red"
  treat_missing_data  = "notBreaching"
  dimensions          = local.opensearch_dimensions

  alarm_actions = [var.alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "opensearch_yellow" {
  alarm_name          = "${var.project}-${var.env}-opensearch-cluster-yellow"
  alarm_description   = "OpenSearch cluster status yellow pendant 5 minutes"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  threshold           = 1
  period              = 60
  statistic           = "Maximum"
  namespace           = "AWS/ES"
  metric_name         = "ClusterStatus.yellow"
  treat_missing_data  = "notBreaching"
  dimensions          = local.opensearch_dimensions

  alarm_actions = [var.alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "opensearch_free_storage" {
  alarm_name          = "${var.project}-${var.env}-opensearch-free-storage-low"
  alarm_description   = "OpenSearch free storage trop bas"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.opensearch_free_storage_threshold_mib
  period              = 60
  statistic           = "Minimum"
  namespace           = "AWS/ES"
  metric_name         = "FreeStorageSpace"
  treat_missing_data  = "notBreaching"
  dimensions          = local.opensearch_dimensions

  alarm_actions = [var.alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "opensearch_writes_blocked" {
  alarm_name          = "${var.project}-${var.env}-opensearch-writes-blocked"
  alarm_description   = "OpenSearch bloque les writes"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  period              = 300
  statistic           = "Maximum"
  namespace           = "AWS/ES"
  metric_name         = "ClusterIndexWritesBlocked"
  treat_missing_data  = "notBreaching"
  dimensions          = local.opensearch_dimensions

  alarm_actions = [var.alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "opensearch_snapshot_failure" {
  alarm_name          = "${var.project}-${var.env}-opensearch-snapshot-failure"
  alarm_description   = "OpenSearch automated snapshot failure"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  period              = 60
  statistic           = "Maximum"
  namespace           = "AWS/ES"
  metric_name         = "AutomatedSnapshotFailure"
  treat_missing_data  = "notBreaching"
  dimensions          = local.opensearch_dimensions

  alarm_actions = [var.alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "opensearch_jvm_pressure" {
  alarm_name          = "${var.project}-${var.env}-opensearch-jvm-pressure"
  alarm_description   = "OpenSearch JVMMemoryPressure >= 95%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  threshold           = 95
  period              = 60
  statistic           = "Maximum"
  namespace           = "AWS/ES"
  metric_name         = "JVMMemoryPressure"
  treat_missing_data  = "notBreaching"
  dimensions          = local.opensearch_dimensions

  alarm_actions = [var.alarm_topic_arn]
}