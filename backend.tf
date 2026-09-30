terraform {
  backend "s3" {
    bucket       = "my-terraform-bucket-lp"
    key          = "aws-env/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}