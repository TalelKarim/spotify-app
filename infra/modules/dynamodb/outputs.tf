output "tracks_table_name" {
  value = aws_dynamodb_table.tracks.name
}

output "users_table_name" {
  value = aws_dynamodb_table.users.name
}

output "listening_events_table_name" {
  value = aws_dynamodb_table.listening_events.name
}
