resource "aws_s3_bucket" "tracks" {
  bucket = "${var.project}-${var.env}-tracks"

  tags = {
    Environment = var.env
    Project     = var.project
    Component   = "media"
  }
}

resource "aws_s3_bucket_versioning" "tracks" {
  bucket = aws_s3_bucket.tracks.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "tracks" {
  bucket = aws_s3_bucket.tracks.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_server_side_encryption_configuration" "tracks" {
  bucket = aws_s3_bucket.tracks.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "tracks" {
  bucket = aws_s3_bucket.tracks.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    filter {}

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}



#Bucket policy- cloudfront only

resource "aws_s3_bucket_policy" "tracks" {
  bucket = aws_s3_bucket.tracks.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontService"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.tracks.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.tracks.arn
          }
        }
      }
    ]
  })
}