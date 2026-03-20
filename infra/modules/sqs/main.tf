resource "aws_sqs_queue" "dlq" {
  count = var.create_dlq ? 1 : 0
  name  = "${var.queue_name}-dlq"
}

resource "aws_sqs_queue" "this" {
  name = var.queue_name

  redrive_policy = var.create_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  }) : null
}

resource "aws_sqs_queue_policy" "eventbridge" {
  count = var.allow_eventbridge ? 1 : 0

  queue_url = aws_sqs_queue.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
      Action   = "sqs:SendMessage"
      Resource = aws_sqs_queue.this.arn
    }]
  })
}