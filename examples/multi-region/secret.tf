## ----------------------------------------------------------------------------
##  Copyright 2023 SevenPico, Inc.
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------
##  ./examples/complete/secret.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------
module "secret" {
  source  = "../.."
  context = module.context.self

  description           = "Example secret"
  secret_ignore_changes = true
  create_sns            = true
  secret_read_principals = {
    AllowRootRead = {
      type = "AWS"
      identifiers = [
        try(data.aws_caller_identity.current[0].account_id, "")
      ]
      condition = {
        test = null
        values = [
        ]
        variable = null
      }
    },
    AllowCooCooRead = {
      type = "AWS"
      identifiers = [
        "516430685960"
      ]
      condition = {
        test = null
        values = [
        ]
        variable = null
      }
    },
    AllowOrgRead = {
      type        = "AWS"
      identifiers = ["*"]
      condition = {
        test     = "ForAnyValue:StringLike"
        values   = ["texas/*"]
        variable = "aws:PrincipalOrgPaths"
      }
    },
    AllowOrgRead2 = {
      type        = "AWS"
      identifiers = ["*"]
      condition = {
        test     = "ForAnyValue:StringLike"
        values   = ["testing/*"]
        variable = "aws:PrincipalOrgPaths"
      }
    }
  }
  sns_pub_principals = {
    AllowRootPub = {
      type = "AWS"
      identifiers = [
        try(data.aws_caller_identity.current[0].account_id, "")
      ]
      condition = {
        test = null
        values = [
        ]
        variable = null
      }
    },
    AllowOrgPub = {
      type        = "AWS"
      identifiers = ["*"]
      condition = {
        test     = "ForAnyValue:StringLike"
        values   = ["abc123def/*"]
        variable = "aws:PrincipalOrgPaths"
      }
    }
  }
  sns_sub_principals = {
    AllowRootSub = {
      type = "AWS"
      identifiers = [
        try(data.aws_caller_identity.current[0].account_id, "")
      ]
      condition = {
        test = null
        values = [
        ]
        variable = null
      }
    },
    AllowOrgSub = {
      type        = "AWS"
      identifiers = ["*"]
      condition = {
        test     = "ForAnyValue:StringLike"
        values   = ["abc123def/*"]
        variable = "aws:PrincipalOrgPaths"
      }
    }
  }

  secret_string = jsonencode({
    abc : 123
  })
  kms_key_multi_region = true
}
