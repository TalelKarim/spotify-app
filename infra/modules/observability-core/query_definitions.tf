resource "aws_cloudwatch_query_definition" "lambda_errors" {
  name            = "${var.project}-${var.env}-lambda-errors"
  log_group_names = var.lambda_log_group_names

  query_string = <<-EOT
    fields @timestamp, @log, @message
    | filter @message like /ERROR|Exception|Traceback|Task timed out|Process exited before completing request/
    | sort @timestamp desc
    | limit 100
  EOT
}

resource "aws_cloudwatch_query_definition" "lambda_recent_activity" {
  name            = "${var.project}-${var.env}-lambda-recent-activity"
  log_group_names = var.lambda_log_group_names

  query_string = <<-EOT
    fields @timestamp, @log, @message
    | sort @timestamp desc
    | limit 200
  EOT
}

resource "aws_cloudwatch_query_definition" "api_access_failures" {
  name            = "${var.project}-${var.env}-api-access-failures"
  log_group_names = [var.api_access_log_group_name]

  query_string = <<-EOT
    fields @timestamp, requestId, httpMethod, resourcePath, status, responseLatency, integrationLatency, ip, errorMessage
    | filter status >= 400
    | sort @timestamp desc
    | limit 100
  EOT
}

resource "aws_cloudwatch_query_definition" "stepfunctions_failures" {
  name            = "${var.project}-${var.env}-stepfunctions-failures"
  log_group_names = [var.step_functions_log_group_name]

  query_string = <<-EOT
    fields @timestamp, @message
    | filter @message like /ExecutionFailed|ExecutionAborted|ExecutionTimedOut|Fail/
    | sort @timestamp desc
    | limit 100
  EOT
}