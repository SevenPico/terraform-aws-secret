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
  value = try(aws_secretsmanager_secret.this[0].arn, "")
}

output "id" {
  value = try(aws_secretsmanager_secret.this[0].id, "")
}

output "kms_key_arn" {
  value = local.kms_key_enabled ? try(data.aws_kms_key.kms_key[0].arn, "") : module.kms_key.key_arn
}

output "kms_key_id" {
  value = local.kms_key_enabled ? try(data.aws_kms_key.kms_key[0].key_id, "") : module.kms_key.key_id
}

output "kms_key_alias_name" {
  value = module.kms_key.alias_name
}

output "kms_key_alias_arn" {
  value = module.kms_key.alias_arn
}

output "sns_topic_arn" {
  value = try(aws_sns_topic.secret_update[0].id, "")
}
