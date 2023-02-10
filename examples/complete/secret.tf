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
