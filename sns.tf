# ------------------------------------------------------------------------------
#  SNS Contexts
# ------------------------------------------------------------------------------
module "secret_update_sns_context" {
  source     = "app.terraform.io/SevenPico/context/null"
  version    = "1.0.1"
  context    = module.context.context
  enabled    = module.context.enabled && var.create_sns
  attributes = ["sns"]
}

module "sns_event_context" {
  source     = "app.terraform.io/SevenPico/context/null"
  version    = "1.0.1"
  context    = module.secret_update_sns_context.context
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

    dynamic "condition" {
      for_each = toset(var.organization_ids)
      content {
        test     = "ForAnyValue:StringLike"
        variable = "aws:PrincipalOrgId"
        values   = condition.value
      }
    }

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

      dynamic "condition" {
        for_each = toset(var.organization_ids)
        content {
          test     = "ForAnyValue:StringLike"
          variable = "aws:PrincipalOrgId"
          values   = condition.value
        }
      }

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
