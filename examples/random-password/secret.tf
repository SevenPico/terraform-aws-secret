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
  source = "../../modules/random-password"
  context = module.context.self

  password_length = 15

  description            = "Example Password"
  secret_ignore_changes  = true
  create_sns             = false
  additional_secrets = {
    USERNAME="admin"
  }
  secret_read_principals = {}
  sns_pub_principals = {}
  sns_sub_principals = {}
}


# Now security reference the value of the password
data "aws_secretsmanager_secret_version" "password" {
  version_stage = "AWSCURRENT"
  secret_id = module.secret.id
}
locals {
  password_secret = jsondecode(
    data.aws_secretsmanager_secret_version.password.secret_string
  )
}

output "username" {
  value = local.password_secret.USERNAME
  sensitive = true
}

output "password" {
  value = local.password_secret.PASSWORD
  sensitive = true
}
