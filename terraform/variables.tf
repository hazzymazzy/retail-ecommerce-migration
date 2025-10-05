variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "ap-southeast-2" # Sydney
}

# Make the bucket name globally unique (change this to your own suffix)
variable "bucket_name_suffix" {
  description = "Unique suffix for the S3 bucket name (e.g., your student ID)"
  type        = string
  default     = "u3223940"  # <-- change if needed
}

locals {
  project_name = "retail-store-demo"
  bucket_name  = "${local.project_name}-${var.bucket_name_suffix}"
  common_tags  = {
    Project = "retail-ecommerce"
    Env     = "dev"
    Owner   = "team"
  }
}
