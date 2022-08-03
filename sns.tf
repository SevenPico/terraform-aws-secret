# ------------------------------------------------------------------------------
#  Secret Update SNS Topic
# ------------------------------------------------------------------------------
module "secret_update_sns_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  enabled    = module.this.enabled && var.create_sns
  attributes = ["sns"]
}

resource "aws_sns_topic" "secret_update" {
  count = module.secret_update_sns_meta.enabled ? 1 : 0

  name                        = module.secret_update_sns_meta.id
  display_name                = module.secret_update_sns_meta.id
  tags                        = module.secret_update_sns_meta.tags
  kms_master_key_id           = ""
  delivery_policy             = null
  fifo_topic                  = false
  content_based_deduplication = false
}

resource "aws_sns_topic_policy" "secret_update" {
  count = module.secret_update_sns_meta.enabled ? 1 : 0

  arn    = one(aws_sns_topic.secret_update[*].arn)
  policy = one(data.aws_iam_policy_document.sns_policy_doc[*].json)
}

data "aws_iam_policy_document" "sns_policy_doc" {
  count = module.secret_update_sns_meta.enabled ? 1 : 0

  policy_id = module.secret_update_sns_meta.id

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
module "sns_event_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.secret_update_sns_meta.context
  attributes = ["event"]
}

resource "aws_cloudwatch_event_rule" "secret_update" {
  count = module.sns_event_meta.enabled ? 1 : 0

  description = "Event on change of secret value"
  name        = "${module.sns_event_meta.id}-rule"
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
  count = module.sns_event_meta.enabled ? 1 : 0

  rule      = one(aws_cloudwatch_event_rule.secret_update[*].name)
  arn       = one(aws_sns_topic.secret_update[*].arn)
  target_id = null
}
