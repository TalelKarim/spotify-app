resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "${var.project}-${var.env}-frontend-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_cache_policy" "frontend_html" {
  name        = "${var.project}-${var.env}-frontend-html"
  comment     = "Short cache for HTML/app shell"
  default_ttl = 60
  min_ttl     = 0
  max_ttl     = 300

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }

    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true
  }
}

resource "aws_cloudfront_cache_policy" "frontend_assets" {
  name        = "${var.project}-${var.env}-frontend-assets"
  comment     = "Long cache for hashed static assets"
  default_ttl = 31536000
  min_ttl     = 86400
  max_ttl     = 31536000

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }

    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true
  }
}

resource "aws_cloudfront_response_headers_policy" "frontend_security" {
  name = "${var.project}-${var.env}-frontend-security"

  security_headers_config {
    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }

    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = false
      override                   = true
    }
  }
}

resource "aws_cloudfront_function" "spa_rewrite" {
  count   = var.enable_spa_rewrite ? 1 : 0
  name    = "${var.project}-${var.env}-spa-rewrite"
  runtime = "cloudfront-js-1.0"
  publish = true
  code    = file("${path.module}/spa_rewrite.js")
}

resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  comment             = "Frontend distribution"
  aliases             = var.aliases
  default_root_object = "index.html"
  price_class         = var.price_class

  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "frontend-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  default_cache_behavior {
    target_origin_id       = "frontend-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    compress = true

    cache_policy_id            = aws_cloudfront_cache_policy.frontend_html.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.frontend_security.id

    dynamic "function_association" {
      for_each = var.enable_spa_rewrite ? [1] : []
      content {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.spa_rewrite[0].arn
      }
    }
  }

  ordered_cache_behavior {
    path_pattern           = "/assets/*"
    target_origin_id       = "frontend-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    compress = true

    cache_policy_id            = aws_cloudfront_cache_policy.frontend_assets.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.frontend_security.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == null
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = var.acm_certificate_arn != null ? "sni-only" : null
    minimum_protocol_version       = var.acm_certificate_arn != null ? "TLSv1.2_2021" : null
  }

  tags = {
    Environment = var.env
    Project     = var.project
    Component   = "frontend"
  }
}




