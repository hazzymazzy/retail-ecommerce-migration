output "website_bucket_name" {
  value       = local.bucket_name
  description = "S3 bucket hosting the website"
}

output "website_endpoint" {
  value       = aws_s3_bucket_website_configuration.site.website_endpoint
  description = "Public website URL (http)"
}
