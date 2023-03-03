provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

module "secret" {
  source = "../.."

  name = "example-secret"

  description            = "Example secret"
  secret_ignore_changes  = true
  create_sns             = true
  secret_read_principals = {
    AllowRootRead = {
      type        = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
      condition = {
        test   = null
        values = [
        ]
        variable = null
      }
    },
    AllowCooCooRead = {
      type        = "AWS"
      identifiers = [
        "516430685960"
      ]
      condition = {
        test   = null
        values = [
        ]
        variable = null
      }
    },
    AllowOrgRead = {
      type        = "AWS"
      identifiers = ["*"]
      condition   = {
        test     = "ForAnyValue:StringLike"
        values   = ["texas/*"]
        variable = "aws:PrincipalOrgPaths"
      }
    },
    AllowOrgRead2 = {
      type        = "AWS"
      identifiers = ["*"]
      condition   = {
        test     = "ForAnyValue:StringLike"
        values   = ["testing/*"]
        variable = "aws:PrincipalOrgPaths"
      }
    }
  }
  sns_pub_principals = {
    AllowRootPub = {
      type        = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
      condition = {
        test   = null
        values = [
        ]
        variable = null
      }
    },
    AllowOrgPub = {
      type        = "AWS"
      identifiers = ["*"]
      condition   = {
        test     = "ForAnyValue:StringLike"
        values   = ["abc123def/*"]
        variable = "aws:PrincipalOrgPaths"
      }
    }
  }
  sns_sub_principals = {
    AllowRootSub = {
      type        = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
      condition = {
        test   = null
        values = [
        ]
        variable = null
      }
    },
    AllowOrgSub = {
      type        = "AWS"
      identifiers = ["*"]
      condition   = {
        test     = "ForAnyValue:StringLike"
        values   = ["abc123def/*"]
        variable = "aws:PrincipalOrgPaths"
      }
    }
  }

  secret_string = jsonencode({
    abc : 123
  })
}
