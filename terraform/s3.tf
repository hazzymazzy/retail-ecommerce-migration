# S3 bucket for static website
resource "aws_s3_bucket" "website" {
  bucket = local.bucket_name
  tags   = local.common_tags
}

# Allow public website policy to work (disable the public-block switches)
resource "aws_s3_bucket_public_access_block" "pab" {
  bucket                  = aws_s3_bucket.website.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Static website hosting (uses S3 website endpoint: http://...)
resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Public read for objects (so the website can be viewed)
resource "aws_s3_bucket_policy" "public_get" {
  bucket = aws_s3_bucket.website.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "PublicReadGetObject",
      Effect    = "Allow",
      Principal = "*",
      Action    = ["s3:GetObject"],
      Resource  = "${aws_s3_bucket.website.arn}/*"
    }]
  })
  depends_on = [aws_s3_bucket_public_access_block.pab]
}

# Lifecycle rule (Cost Optimisation): move objects to Glacier after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "lc" {
  bucket = aws_s3_bucket.website.id

  rule {
    id     = "to-glacier-after-30-days"
    status = "Enabled"

    # Required by provider: choose what the rule applies to ("" means whole bucket)
    filter { prefix = "" }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }
  }
}

# Upload site files from ../website (index.html, error.html, assets...)
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
  depends_on = [aws_s3_bucket_policy.public_get]
}
