variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "ap-southeast-2" # Sydney
}

# S3 bucket names must be globally unique
variable "bucket_name_suffix" {
  description = "Unique suffix for the S3 bucket name"
  type        = string
  default     = "hazzy-uc-2025"   # chosen suffix
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
