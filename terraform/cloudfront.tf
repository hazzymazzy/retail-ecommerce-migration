cat > cloudfront.tf <<'EOF'
# CloudFront distribution using S3 Website (custom origin, no OAC, no TF-managed S3)
resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"  # sandbox-friendly
  tags                = local.common_tags

  origin {
    domain_name = var.s3_website_origin  # e.g. my-bucket.s3-website-ap-southeast-2.amazonaws.com
    origin_id   = "s3-website-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"   # S3 website endpoints are HTTP-only
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "s3-website-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  restrictions { geo_restriction { restriction_type = "none" } }
  viewer_certificate { cloudfront_default_certificate = true }
}

output "cloudfront_url" {
  value       = "https://${aws_cloudfront_distribution.cdn.domain_name}"
  description = "Public HTTPS URL via CloudFront"
}
EOF
