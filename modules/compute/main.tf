resource "aws_security_group" "myapp_sg" {
  name        = "myapp-sg-${var.environment}"
  description = "No inbound access; outbound only for the SSM agent"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "myapp_sg_egress" {
  security_group_id = aws_security_group.myapp_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
  description = "Allow all outbound traffic"
}

# Trust policy: lets EC2 assume the role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_ssm_role" {
  name               = "ec2-ssm-managed-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# AWS-managed policy the SSM agent needs to register and run sessions
resource "aws_iam_role_policy_attachment" "ssm_policy_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile-${var.environment}"
  role = aws_iam_role.ec2_ssm_role.name
}

# Latest AL2023 AMI ID, published by AWS in Parameter Store
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "app" {
  ami                    = data.aws_ssm_parameter.al2023.insecure_value
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.myapp_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  associate_public_ip_address = true

  # Encrypt the root EBS volume at rest (AWS-managed key, no extra cost)
  root_block_device {
    encrypted = true
  }

  # Require IMDSv2: metadata requests need a session token
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Project, Environment and ManagedBy come from the provider's default_tags
  tags = {
    Name = "myapp-${var.environment}"
  }

  lifecycle {
    postcondition {
      condition     = self.public_ip != null && self.public_ip != ""
      error_message = "Instance was created but public IP wasn't obtained"
    }

    # A new AMI release changes the parameter's value; without this, the
    # next plan would replace the instance
    ignore_changes = [ami]
  }
}
