terraform {
  required_version = ">= 1.10"

  # A module sets a minimum only; the root module's versions.tf picks the exact major
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
