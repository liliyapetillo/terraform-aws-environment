terraform {
  # use_lockfile in backend.tf (S3 native state locking) needs Terraform 1.10+
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
