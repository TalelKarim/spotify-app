output "tracks_table_name" {
  value = aws_dynamodb_table.tracks.name
}

output "tracks_table_arn" {
  value = aws_dynamodb_table.tracks.arn
}

output "users_table_name" {
  value = aws_dynamodb_table.users.name
}


output "users_table_arn" {
  value = aws_dynamodb_table.users.arn
}


output "listening_events_table_name" {
  value = aws_dynamodb_table.listening_events.name
}


output "listening_events_table_arn" {
  value = aws_dynamodb_table.listening_events.arn
}



output "analytics_table_name" {
  value = aws_dynamodb_table.analytics.name
}

output "analytics_table_arn" {
  value = aws_dynamodb_table.analytics.arn
}
