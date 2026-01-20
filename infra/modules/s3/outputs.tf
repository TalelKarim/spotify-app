output "frontend_bucket_name" {
  value = aws_s3_bucket.frontend.bucket
}

output "audio_bucket_name" {
  value = aws_s3_bucket.audio.bucket
}
