output "bucket_name" {
  value = aws_s3_bucket.tracks.bucket
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.tracks.domain_name
}

output "cloudfront_arn" {
  value = aws_cloudfront_distribution.tracks.arn
}