output "website_bucket_name" {
  value       = local.bucket_name
  description = "S3 bucket storing site content (private)"
}

# The public URL is now served by CloudFront
output "cloudfront_url" {
  value       = "https://${aws_cloudfront_distribution.cdn.domain_name}"
  description = "Public HTTPS URL for the site"
}
