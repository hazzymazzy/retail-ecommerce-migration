terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.20.0" # pinned to avoid Object Lock read denied in Academy
    }
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2" # Sydney
}

variable "bucket_name_suffix" {
  description = "Globally-unique suffix for S3 bucket (e.g., hazzy-uc-2025)"
  type        = string
  default     = "hazzy-uc-2025"
}

provider "aws" { region = var.aws_region }

locals {
  project_name = "retail-store-demo"
  bucket_name  = "${local.project_name}-${var.bucket_name_suffix}"
  common_tags  = { Project = "retail-ecommerce", Env = "dev", Owner = "team" }
}

# --- Create PRIVATE S3 bucket via AWS CLI (avoids forbidden GetBucketObjectLockConfiguration) ---
resource "null_resource" "create_bucket" {
  triggers = { bucket_name = local.bucket_name, region = var.aws_region }
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
set -e
# Create bucket if it doesn't exist
if ! aws s3api head-bucket --bucket ${local.bucket_name} 2>/dev/null; then
  if [ "${var.aws_region}" = "us-east-1" ]; then
    aws s3api create-bucket --bucket ${local.bucket_name}
  else
    aws s3api create-bucket --bucket ${local.bucket_name} --create-bucket-configuration LocationConstraint=${var.aws_region}
  fi
fi
# Block ALL public access
aws s3api put-public-access-block \
  --bucket ${local.bucket_name} \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
# Optional lifecycle: transition to GLACIER after 30 days (cost optimisation)
aws s3api put-bucket-lifecycle-configuration \
  --bucket ${local.bucket_name} \
  --lifecycle-configuration '{"Rules":[{"ID":"to-glacier-after-30-days","Status":"Enabled","Filter":{"Prefix":""},"Transitions":[{"Days":30,"StorageClass":"GLACIER"}]}]}'
EOT
  }
}

# Upload website files after bucket exists
resource "aws_s3_object" "site_files" {
  for_each = fileset("${path.module}/../website", "*.*")
  bucket   = local.bucket_name
  key      = each.value
  source   = "${path.module}/../website/${each.value}"
  etag     = filemd5("${path.module}/../website/${each.value}")
  content_type = lookup(
    { html = "text/html", css = "text/css", js = "application/javascript", png = "image/png",
    jpg = "image/jpeg", jpeg = "image/jpeg", gif = "image/gif", svg = "image/svg+xml" },
    split(".", each.value)[length(split(".", each.value)) - 1],
    "application/octet-stream"
  )
  depends_on = [null_resource.create_bucket]
}

# CloudFront + OAC serves PRIVATE S3 over HTTPS
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${local.bucket_name}-oac"
  description                       = "OAC for private S3 origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    origin_id = "s3-origin"
    # S3 REST endpoint for the private bucket
    domain_name              = "${local.bucket_name}.s3.${var.aws_region}.amazonaws.com"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    s3_origin_config {
      origin_access_identity = "" # required; OAC handles auth
    }
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags       = local.common_tags
  depends_on = [null_resource.create_bucket]
}

# Only this CloudFront distribution can read the bucket
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = local.bucket_name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid : "AllowCloudFrontServicePrincipalReadOnly",
      Effect : "Allow",
      Principal : { "Service" : "cloudfront.amazonaws.com" },
      Action : ["s3:GetObject"],
      Resource : "arn:aws:s3:::${local.bucket_name}/*",
      Condition : { StringEquals : {
        "AWS:SourceArn" : "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.cdn.id}"
      } }
    }]
  })
  depends_on = [null_resource.create_bucket, aws_cloudfront_distribution.cdn]
}

# Outputs
output "website_bucket_name" {
  value = local.bucket_name
}
output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.cdn.domain_name}"
}
