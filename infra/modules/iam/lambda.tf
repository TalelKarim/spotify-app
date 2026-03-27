############################
# IAM Roles
############################

resource "aws_iam_role" "step_functions" {
  name = "${var.project_name}-step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}



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



resource "aws_iam_role" "lambda_tech" {
  name = "${var.project_name}-lambda-tech-role"

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
# Opensearch
############################



# Policy pour consommer le stream + écrire dans OpenSearch
data "aws_iam_policy_document" "lambda_search_indexer" {
  statement {
    sid    = "DynamoDBStreamRead"
    effect = "Allow"
    actions = [
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListStreams"
    ]
    resources = [
      var.tracks_stream_arn
    ]
  }

  statement {
    sid    = "OpenSearchIndexWrite"
    effect = "Allow"
    actions = [
      "es:ESHttpGet",
      "es:ESHttpPost",
      "es:ESHttpPut",
      "es:ESHttpDelete"
    ]
    resources = [
      "${var.opensearch_domain_arn}/*"
    ]
  }
}




data "aws_iam_policy_document" "lambda_api_search" {
  statement {
    sid    = "OpenSearchSearchRead"
    effect = "Allow"
    actions = [
      "es:ESHttpGet",
      "es:ESHttpPost" # pour /_search en POST
    ]
    resources = [
      "${var.opensearch_domain_arn}/*"
    ]
  }
}



############################
# Logging for the step functions 
############################


resource "aws_iam_policy" "step_functions_logging" {
  name = "${var.project_name}-step-functions-logging"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogDelivery",
        "logs:CreateLogStream",
        "logs:GetLogDelivery",
        "logs:UpdateLogDelivery",
        "logs:DeleteLogDelivery",
        "logs:ListLogDeliveries",
        "logs:PutLogEvents",
        "logs:PutResourcePolicy",
        "logs:DescribeResourcePolicies",
        "logs:DescribeLogGroups"
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
# S3 Policies 
############################


resource "aws_iam_policy" "lambda_api_s3" {
  name = "${var.project_name}-lambda-api-s3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      "Effect" : "Allow",
      "Action" : [
        "s3:PutObject"
      ],
      "Resource" : "arn:aws:s3:::${var.media_bucket_name}/*"
    }]
  })
}





resource "aws_iam_policy" "lambda_event_s3" {
  name = "${var.project_name}-lambda-event-s3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::${var.media_bucket_name}"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::${var.media_bucket_name}/*"
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
        "dynamodb:BatchGetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:TransactWriteItems"
      ]
      Resource = concat(
        var.dynamodb_table_arns.api,
        [
          for arn in var.dynamodb_table_arns.api :
          "${arn}/index/*"
        ]
      )
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
        "dynamodb:GetItem",
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



resource "aws_iam_role_policy_attachment" "tech_logs" {
  role       = aws_iam_role.lambda_tech.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}


resource "aws_iam_role_policy_attachment" "step_functions_logging" {
  role       = aws_iam_role.step_functions.name
  policy_arn = aws_iam_policy.step_functions_logging.arn
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




resource "aws_iam_role_policy_attachment" "tech_xray" {
  role       = aws_iam_role.lambda_tech.name
  policy_arn = aws_iam_policy.lambda_xray.arn
}

resource "aws_iam_role_policy_attachment" "step_functions_xray" {
  role       = aws_iam_role.step_functions.name
  policy_arn = aws_iam_policy.step_functions_xray.arn
}


#s3


resource "aws_iam_role_policy_attachment" "api_s3" {
  role       = aws_iam_role.lambda_api.name
  policy_arn = aws_iam_policy.lambda_api_s3.arn
}


resource "aws_iam_role_policy_attachment" "event_s3" {
  role       = aws_iam_role.lambda_events.name
  policy_arn = aws_iam_policy.lambda_event_s3.arn
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

resource "aws_iam_role_policy_attachment" "tech_kms" {
  role       = aws_iam_role.lambda_tech.name
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


resource "aws_iam_role_policy_attachment" "tech_dynamodb" {
  role       = aws_iam_role.lambda_tech.name
  policy_arn = aws_iam_policy.lambda_orch_dynamodb.arn
}


resource "aws_iam_role_policy_attachment" "api_eventbridge_put" {
  role       = aws_iam_role.lambda_api.name
  policy_arn = aws_iam_policy.lambda_eventbridge_put.arn
}



#vpc access
resource "aws_iam_role_policy_attachment" "vpc_access_tech" {
  role       = aws_iam_role.lambda_tech.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


resource "aws_iam_role_policy_attachment" "vpc_access_api" {
  role       = aws_iam_role.lambda_api.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}



# opensearch
resource "aws_iam_policy" "lambda_search_indexer" {
  name   = "lambda-search-indexer"
  policy = data.aws_iam_policy_document.lambda_search_indexer.json
}

resource "aws_iam_role_policy_attachment" "lambda_search_indexer" {
  role       = aws_iam_role.lambda_tech.name
  policy_arn = aws_iam_policy.lambda_search_indexer.arn
}



resource "aws_iam_policy" "lambda_api_search" {
  name   = "lambda-api-search"
  policy = data.aws_iam_policy_document.lambda_api_search.json
}

resource "aws_iam_role_policy_attachment" "lambda_api_search" {
  role       = aws_iam_role.lambda_api.name
  policy_arn = aws_iam_policy.lambda_api_search.arn
}
