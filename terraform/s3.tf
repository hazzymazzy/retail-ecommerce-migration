# PRIVATE S3 bucket for site content (no public access)
resource "aws_s3_bucket" "website" {
  bucket = local.bucket_name
  tags   = local.common_tags
}

# Block ALL public access
resource "aws_s3_bucket_public_access_block" "pab" {
  bucket                  = aws_s3_bucket.website.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Optional lifecycle rule (cost optimisation)
resource "aws_s3_bucket_lifecycle_configuration" "lc" {
  bucket = aws_s3_bucket.website.id

  rule {
    id     = "to-glacier-after-30-days"
    status = "Enabled"
    filter { prefix = "" }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }
  }
}

# Upload files from ../website (index.html, error.html, assets...)
resource "aws_s3_object" "site_files" {
  for_each     = fileset("${path.module}/../website", "*.*")
  bucket       = aws_s3_bucket.website.id
  key          = each.value
  source       = "${path.module}/../website/${each.value}"
  etag         = filemd5("${path.module}/../website/${each.value}")
  content_type = lookup(
    {
      html = "text/html",
      css  = "text/css",
      js   = "application/javascript",
      png  = "image/png",
      jpg  = "image/jpeg",
      jpeg = "image/jpeg",
      gif  = "image/gif",
      svg  = "image/svg+xml"
    },
    split(".", each.value)[length(split(".", each.value)) - 1],
    "application/octet-stream"
  )
  depends_on = [aws_s3_bucket_public_access_block.pab]
}
