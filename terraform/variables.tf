# variables.tf (adds s3_website_origin)
cat > variables.tf <<'EOF'
variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "ap-southeast-2" # Sydney
}

# Kept for compatibility (unused when S3 is CLI-managed)
variable "bucket_name_suffix" {
  description = "Unique suffix for S3 bucket (unused in this path)"
  type        = string
  default     = "hazzy-uc-2025"
}

# REQUIRED: pass S3 website endpoint hostname to CloudFront
# e.g. retail-demo-1700000000.s3-website-ap-southeast-2.amazonaws.com
variable "s3_website_origin" {
  description = "S3 website endpoint hostname for CloudFront custom origin"
  type        = string
}

locals {
  project_name = "retail-store-demo"
  bucket_name  = "${local.project_name}-${var.bucket_name_suffix}"

  common_tags = {
    Project = "retail-ecommerce"
    Env     = "dev"
    Owner   = "team"
  }
}
EOF
