############################
# IAM Roles
############################

resource "aws_iam_role" "lambda_api" {
  name = "${var.project_name}-lambda-api-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role" "lambda_events" {
  name = "${var.project_name}-lambda-events-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role" "lambda_step_functions" {
  name = "${var.project_name}-lambda-step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

############################
# IAM Policy - CloudWatch Logs
############################

resource "aws_iam_policy" "lambda_logs" {
  name = "${var.project_name}-lambda-logs-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "*"
    }]
  })
}

############################
# IAM Policy - X-Ray
############################

resource "aws_iam_policy" "lambda_xray" {
  name = "${var.project_name}-lambda-xray-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ]
      Resource = "*"
    }]
  })
}

############################
# IAM Policy - KMS (minimal)
############################

resource "aws_iam_policy" "lambda_kms" {
  name = "${var.project_name}-lambda-kms-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ]
      Resource = "*"
    }]
  })
}

############################
# Attach policies to roles
############################

resource "aws_iam_role_policy_attachment" "api_logs" {
  role       = aws_iam_role.lambda_api.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}

resource "aws_iam_role_policy_attachment" "events_logs" {
  role       = aws_iam_role.lambda_events.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}

resource "aws_iam_role_policy_attachment" "steps_logs" {
  role       = aws_iam_role.lambda_step_functions.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}

resource "aws_iam_role_policy_attachment" "api_xray" {
  role       = aws_iam_role.lambda_api.name
  policy_arn = aws_iam_policy.lambda_xray.arn
}

resource "aws_iam_role_policy_attachment" "events_xray" {
  role       = aws_iam_role.lambda_events.name
  policy_arn = aws_iam_policy.lambda_xray.arn
}

resource "aws_iam_role_policy_attachment" "steps_xray" {
  role       = aws_iam_role.lambda_step_functions.name
  policy_arn = aws_iam_policy.lambda_xray.arn
}

resource "aws_iam_role_policy_attachment" "api_kms" {
  role       = aws_iam_role.lambda_api.name
  policy_arn = aws_iam_policy.lambda_kms.arn
}

resource "aws_iam_role_policy_attachment" "events_kms" {
  role       = aws_iam_role.lambda_events.name
  policy_arn = aws_iam_policy.lambda_kms.arn
}

resource "aws_iam_role_policy_attachment" "steps_kms" {
  role       = aws_iam_role.lambda_step_functions.name
  policy_arn = aws_iam_policy.lambda_kms.arn
}
