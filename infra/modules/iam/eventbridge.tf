resource "aws_iam_role" "eventbridge_stepfn" {
  name = "${var.project_name}-eventbridge-stepfn-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_policy" "eventbridge_stepfn_start" {
  name = "${var.project_name}-eventbridge-stepfn-start"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "states:StartExecution"
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eventbridge_stepfn_attach" {
  role       = aws_iam_role.eventbridge_stepfn.name
  policy_arn = aws_iam_policy.eventbridge_stepfn_start.arn
}
