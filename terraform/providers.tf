terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.67.0"   # sandbox-safe (avoids S3 Object Lock read)
    }
  }
}

provider "aws" {
  region = var.aws_region
}
