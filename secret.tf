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
##  ./secret.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Secret Contexts
# ------------------------------------------------------------------------------
module "secret_context" {
  source     = "SevenPico/context/null"
  version    = "2.0.0"
  context    = module.context.self
  enabled    = module.context.enabled
  attributes = ["secret"]
}

module "secret_kms_key_context" {
  source     = "SevenPico/context/null"
  version    = "2.0.0"
  context    = module.secret_context.self
  attributes = ["kms", "key"]
}

# ------------------------------------------------------------------------------
# KMS Key IAM
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "kms_key_access_policy_doc" {
  count = module.context.enabled && length(var.secret_read_principals) == 0 ? 0 : 1

  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  dynamic "statement" {
    for_each = length(var.secret_read_principals) == 0 ? [] : [1]
    content {
      effect    = "Allow"
      sid       = "Allow secret decrypt"
      actions   = ["kms:Decrypt"]
      resources = ["*"]

      dynamic "principals" {
        for_each = var.secret_read_principals
        content {
          type        = principals.key
          identifiers = principals.value
        }
      }
    }
  }
}


# ------------------------------------------------------------------------------
# KMS Key
# ------------------------------------------------------------------------------
module "kms_key" {
  source  = "SevenPicoForks/kms-key/aws"
  version = "2.0.0"
  context = module.secret_kms_key_context.self

  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = var.kms_key_deletion_window_in_days
  description              = "KMS key for ${module.context.id}"
  enable_key_rotation      = var.kms_key_enable_key_rotation
  key_usage                = "ENCRYPT_DECRYPT"
  multi_region             = false
  policy                   = join("", data.aws_iam_policy_document.kms_key_access_policy_doc[*].json)
}


# ------------------------------------------------------------------------------
# Secret
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "secret_access_policy_doc" {
  count = module.context.enabled && length(var.secret_read_principals) == 0 ? 0 : 1

  dynamic "statement" {
    for_each = length(var.secret_read_principals) == 0 ? [] : [1]
    content {
      effect = "Allow"
      actions = [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ]
      resources = ["*"]

      dynamic "principals" {
        for_each = var.secret_read_principals
        content {
          type        = principals.key
          identifiers = principals.value
        }
      }
    }
  }
}

resource "aws_secretsmanager_secret" "this" {
  count = module.secret_context.enabled ? 1 : 0

  description = var.description
  kms_key_id  = module.kms_key.key_id
  name_prefix = "${module.secret_context.id}-"
  policy      = one(data.aws_iam_policy_document.secret_access_policy_doc[*].json)
  tags        = module.secret_context.tags
}

resource "aws_secretsmanager_secret_version" "default" {
  count = (module.secret_context.enabled && !var.secret_ignore_changes) ? 1 : 0

  secret_id     = one(aws_secretsmanager_secret.this[*].id)
  secret_string = var.secret_string
}

resource "aws_secretsmanager_secret_version" "ignore_changes" {
  count = (module.secret_context.enabled && var.secret_ignore_changes) ? 1 : 0

  secret_id     = one(aws_secretsmanager_secret.this[*].id)
  secret_string = var.secret_string

  lifecycle {
    ignore_changes = [secret_string, secret_binary]
  }
}
