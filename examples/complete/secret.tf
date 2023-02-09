provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

module "secret" {
  source = "../.."

  name = "example-secret"

  description = "Example secret"
  secret_ignore_changes  = true
  create_sns             = true
  secret_read_principals = { AWS = [data.aws_caller_identity.current.account_id] }
  sns_pub_principals     = { AWS = [data.aws_caller_identity.current.account_id] }
  sns_sub_principals     = { AWS = [data.aws_caller_identity.current.account_id] }

  secret_string = jsonencode({
    abc : 123
  })
}
