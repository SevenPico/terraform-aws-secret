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
##  ./sns.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

# ------------------------------------------------------------------------------
#  SNS Contexts
# ------------------------------------------------------------------------------
module "secret_update_sns_context" {
  source     = "SevenPico/context/null"
  version    = "1.1.0"
  context    = module.context.self
  enabled    = module.context.enabled && var.create_sns
  attributes = ["sns"]
}

module "sns_event_context" {
  source     = "SevenPico/context/null"
  version    = "1.1.0"
  context    = module.secret_update_sns_context.self
  attributes = ["event"]
}


# ------------------------------------------------------------------------------
#  Secret Update SNS Topic
# ------------------------------------------------------------------------------
resource "aws_sns_topic" "secret_update" {
  count = module.secret_update_sns_context.enabled ? 1 : 0

  name                        = module.secret_update_sns_context.id
  display_name                = module.secret_update_sns_context.id
  tags                        = module.secret_update_sns_context.tags
  kms_master_key_id           = module.kms_key.key_id
  delivery_policy             = null
  fifo_topic                  = false
  content_based_deduplication = false
}

resource "aws_sns_topic_policy" "secret_update" {
  count = module.secret_update_sns_context.enabled ? 1 : 0

  arn    = aws_sns_topic.secret_update[0].arn
  policy = data.aws_iam_policy_document.sns_policy_doc[0].json
}

data "aws_iam_policy_document" "sns_policy_doc" {
  count = module.secret_update_sns_context.enabled ? 1 : 0

  policy_id = module.secret_update_sns_context.id

  statement {
    sid       = "AllowPub"
    effect    = "Allow"
    actions   = ["SNS:Publish"]
    resources = [one(aws_sns_topic.secret_update[*].arn)]

    principals {
      type        = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com",
        "events.amazonaws.com"
      ]
    }

    dynamic "principals" {
      for_each = local.sns_pub_principals
      content {
        type        = principals.value.type
        identifiers = principals.value.identifiers
      }
    }
  }

  dynamic "statement" {
    for_each = local.sns_pub_principals_with_condition
    content {
      sid       = statement.key
      effect    = "Allow"
      actions   = ["SNS:Publish"]
      resources = [one(aws_sns_topic.secret_update[*].arn)]

      principals {
        type        = statement.value.type
        identifiers = statement.value.identifiers
      }
      condition {
        test     = statement.value.condition.test
        values   = statement.value.condition.values
        variable = statement.value.condition.variable
      }
    }
  }

  dynamic "statement" {
    for_each = local.sns_sub_principals
    content {
      sid       = statement.key
      effect    = "Allow"
      actions   = ["SNS:Subscribe"]
      resources = [one(aws_sns_topic.secret_update[*].arn)]

      principals {
        type        = statement.value.type
        identifiers = statement.value.identifiers
      }
    }
  }

  dynamic "statement" {
    for_each = local.sns_sub_principals_with_condition
    content {
      sid       = statement.key
      effect    = "Allow"
      actions   = ["SNS:Subscribe"]
      resources = [one(aws_sns_topic.secret_update[*].arn)]

      principals {
        type        = statement.value.type
        identifiers = statement.value.identifiers
      }
      condition {
        test     = statement.value.condition.test
        values   = statement.value.condition.values
        variable = statement.value.condition.variable
      }
    }
  }
}
