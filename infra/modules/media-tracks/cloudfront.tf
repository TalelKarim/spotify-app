#OAC

resource "aws_cloudfront_origin_access_control" "tracks" {
  name                              = "${var.project}-${var.env}-tracks-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#Distribution
resource "aws_cloudfront_distribution" "tracks" {

  enabled = true
  comment = "Tracks distribution"

  origin {
    domain_name              = aws_s3_bucket.tracks.bucket_regional_domain_name
    origin_id                = "tracks-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.tracks.id
  }

  default_cache_behavior {
    target_origin_id       = "tracks-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    compress = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = var.price_class

  tags = {
    Environment = var.env
    Project     = var.project
    Component   = "media"
  }
}


