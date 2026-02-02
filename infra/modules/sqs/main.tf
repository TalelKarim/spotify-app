resource "aws_sqs_queue" "this" {
  name = var.queue_name
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
