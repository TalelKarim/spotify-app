resource "aws_iam_policy" "sqs_consume" {
  count = var.sqs_link ? 1 : 0

  name = "${var.function_name}-sqs-consume"

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
      Resource = var.sqs_queue_arns
    }]
  })
}

resource "aws_iam_role_policy_attachment" "sqs_consume" {
  count      = var.sqs_link ? 1 : 0
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.sqs_consume[0].arn
}
