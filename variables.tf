variable "instance_types" {
  description = "EC2 instance size per workspace. Picked by the selected workspace, so a plain `terraform apply` can't resize production by forgetting a -var flag."
  type        = map(string)
  default = {
    staging    = "t3.micro"
    production = "t3.small"
  }
}

variable "region" {
  description = "The AWS region to deploy into. The backend region in backend.tf is set separately, since backends can't read variables."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Public subnet CIDRs are computed from it."
  type        = string
  default     = "10.0.0.0/16"
}
