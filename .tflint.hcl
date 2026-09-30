plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# AWS-specific rules, e.g. catches invalid instance types before apply
plugin "aws" {
  enabled = true
  version = "0.40.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
