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
  source     = "app.terraform.io/SevenPico/context/null"
  version    = "1.1.0"
  context    = module.context.self
  enabled    = module.context.enabled && var.create_sns
  attributes = ["sns"]
}

module "sns_event_context" {
  source     = "app.terraform.io/SevenPico/context/null"
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
      type = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com",
        "events.amazonaws.com"
      ]
    }

    dynamic "principals" {
      for_each = var.sns_pub_principals
      content {
        type        = principals.key
        identifiers = principals.value
      }
    }
  }

  dynamic "statement" {
    for_each = var.sns_sub_principals
    content {
      effect    = "Allow"
      actions   = ["SNS:Subscribe"]
      resources = [one(aws_sns_topic.secret_update[*].arn)]

      principals {
        type        = statement.key
        identifiers = statement.value
      }
    }
  }
}


# ------------------------------------------------------------------------------
#  Secret Update CloudWatch Event to SNS
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "secret_update" {
  count = module.sns_event_context.enabled ? 1 : 0

  description = "Event on change of secret value"
  name        = "${module.sns_event_context.id}-rule"
  is_enabled  = true

  event_pattern = jsonencode({
    source      = ["aws.secretsmanager"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["secretsmanager.amazonaws.com"],
      eventName   = ["PutSecretValue", "UpdateSecret", "UpdateSecretVersionStage"]
      requestParameters = {
        secretId = [one(aws_secretsmanager_secret.this[*].arn)]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "secret_update" {
  count = module.sns_event_context.enabled ? 1 : 0

  rule      = one(aws_cloudwatch_event_rule.secret_update[*].name)
  arn       = one(aws_sns_topic.secret_update[*].arn)
  target_id = null
}
