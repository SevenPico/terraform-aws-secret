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
##  ./_outputs.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

output "arn" {
  value = module.secret.arn
}

output "id" {
  value = module.secret.id
}

output "kms_key_arn" {
  value = module.secret.kms_key_arn
}

output "kms_key_alias_name" {
  value = module.secret.kms_key_alias_name
}

output "kms_key_alias_arn" {
  value = module.secret.kms_key_alias_arn
}

output "sns_topic_arn" {
  value = module.secret.sns_topic_arn
}
