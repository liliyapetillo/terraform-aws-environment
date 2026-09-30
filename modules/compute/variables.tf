variable "environment" {
  description = "The environment name, taken from the Terraform workspace. Only staging and production are allowed."
  type        = string

  # Stops an accidental apply from the "default" workspace, which would
  # otherwise create a third, unintended copy of the stack named "-default"
  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Select the staging or production workspace first (terraform workspace select staging). Current workspace: \"${var.environment}\"."
  }
}

variable "vpc_id" {
  description = "The ID of the VPC passed down from the root module."
  type        = string
}

variable "subnet_id" {
  description = "The Subnet ID of the subnet passed down from the root module."
  type        = string
}

variable "instance_type" {
  description = "The size of the EC2 instance to deploy."
  type        = string

  validation {
    condition     = contains(["t3.micro", "t3.small"], var.instance_type)
    error_message = "The instance_type must be either 't3.micro' or 't3.small'."
  }
}
