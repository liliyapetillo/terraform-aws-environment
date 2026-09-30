provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "myapp"
      Environment = terraform.workspace
      ManagedBy   = "terraform"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  environment = terraform.workspace
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "myapp-vpc-${local.environment}"
  cidr = var.vpc_cidr

  azs                  = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets       = [for i in range(2) : cidrsubnet(var.vpc_cidr, 8, i)]
  enable_dns_hostnames = true
}

module "compute" {
  source        = "./modules/compute"
  vpc_id        = module.vpc.vpc_id
  environment   = local.environment
  subnet_id     = module.vpc.public_subnets[0]
  instance_type = var.instance_types[local.environment]
}