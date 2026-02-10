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
# Put events to eventbridge policy
############################



resource "aws_iam_policy" "lambda_eventbridge_put" {
  name = "${var.project_name}-lambda-eventbridge-put-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "events:PutEvents"
        ]
        Resource = var.eventbridge_bus_arn
      }
    ]
  })
}



############################
# Dynamodb Policies 
############################


resource "aws_iam_policy" "lambda_api_dynamodb" {
  name = "${var.project_name}-lambda-api-dynamodb"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:UpdateItem"
      ]
      Resource = var.dynamodb_table_arns.api
    }]
  })
}


resource "aws_iam_policy" "lambda_events_dynamodb" {
  name = "${var.project_name}-lambda-events-dynamodb"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ]
      Resource = var.dynamodb_table_arns.events
    }]
  })
}



resource "aws_iam_policy" "lambda_orch_dynamodb" {
  name = "${var.project_name}-lambda-orch-dynamodb"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:UpdateItem",
        "dynamodb:PutItem"
      ]
      Resource = var.dynamodb_table_arns.orch
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
# SQS Policies
############################


resource "aws_iam_policy" "lambda_sqs_consume" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ChangeMessageVisibility"
      ]
      Resource = var.sqs_queue_arn
    }]
  })
}



############################
# Attach policies to roles
############################





# cloudwatch logs 
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


#sqs

resource "aws_iam_role_policy_attachment" "sqs_access" {
  role       = aws_iam_role.lambda_events.name
  policy_arn = aws_iam_policy.lambda_sqs_consume.arn
}




# x ray 

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



# chiffrement kms

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



# dynamodb 
resource "aws_iam_role_policy_attachment" "api_dynamodb" {
  role       = aws_iam_role.lambda_api.name
  policy_arn = aws_iam_policy.lambda_api_dynamodb.arn
}



resource "aws_iam_role_policy_attachment" "events_dynamodb" {
  role       = aws_iam_role.lambda_events.name
  policy_arn = aws_iam_policy.lambda_events_dynamodb.arn
}

resource "aws_iam_role_policy_attachment" "orch_dynamodb" {
  role       = aws_iam_role.lambda_step_functions.name
  policy_arn = aws_iam_policy.lambda_orch_dynamodb.arn
}




resource "aws_iam_role_policy_attachment" "api_eventbridge_put" {
  role       = aws_iam_role.lambda_api.name
  policy_arn = aws_iam_policy.lambda_eventbridge_put.arn
}
