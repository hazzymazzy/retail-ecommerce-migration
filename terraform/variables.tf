cat > variables.tf <<'EOF'
variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "ap-southeast-2"
}

# kept for compatibility (unused when S3 is CLI-managed)
variable "bucket_name_suffix" {
  description = "Unique suffix for S3 bucket (unused in this path)"
  type        = string
  default     = "hazzy-uc-2025"
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
