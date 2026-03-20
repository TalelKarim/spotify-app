output "queue_name" {
  value = aws_sqs_queue.this.name
}

output "queue_arn" {
  value = aws_sqs_queue.this.arn
}

output "queue_url" {
  value = aws_sqs_queue.this.id
}

output "dlq_queue_name" {
  value = var.create_dlq ? aws_sqs_queue.dlq[0].name : null
}

output "dlq_queue_arn" {
  value = var.create_dlq ? aws_sqs_queue.dlq[0].arn : null
}

output "dlq_queue_url" {
  value = var.create_dlq ? aws_sqs_queue.dlq[0].id : null
}