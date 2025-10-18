variable "aws_region" {
  description = "AWS region to deploy to"
variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "ap-southeast-2" # Sydney
}

# S3 bucket names must be globally unique
variable "bucket_name_suffix" {
  description = "Unique suffix for the S3 bucket name"
  type        = string
  default     = "hazzy-uc-2025"   # chosen suffix (ignored once we handle S3 via CLI)
}

# ✅ ADD THIS NEW BLOCK ↓
variable "s3_website_origin" {
  description = "S3 website endpoint hostname (e.g., retail-demo-123.s3-website-ap-southeast-2.amazonaws.com)"
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
