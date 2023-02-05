# ------------------------------------------------------------------------------
# KMS Key
# ------------------------------------------------------------------------------
data "context" "sns" {
  context = data.context.this
  enabled = var.sns_enabled
}


# ------------------------------------------------------------------------------
#  Secret Update SNS Topic
# ------------------------------------------------------------------------------
resource "aws_sns_topic" "secret_update" {
  count = data.context.sns.enabled ? 1 : 0

  name                        = data.context.sns.id
  display_name                = data.context.sns.id
  tags                        = data.context.sns.tags
  kms_master_key_id           = data.context.kms.enabled ? aws_kms_key.this[0].key_id : null
  delivery_policy             = null
  fifo_topic                  = false
  content_based_deduplication = false
}

resource "aws_sns_topic_policy" "secret_update" {
  count = data.context.sns.enabled ? 1 : 0

  arn    = aws_sns_topic.secret_update[0].arn
  policy = data.aws_iam_policy_document.sns_policy_doc[0].json
}

data "aws_iam_policy_document" "sns_policy_doc" {
  count = data.context.sns.enabled ? 1 : 0

  policy_id = data.context.sns.id

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
  count = data.context.sns.enabled ? 1 : 0

  description = "Event on change of secret value"
  name        = "${data.context.sns.id}-rule"
  is_enabled  = true

  event_pattern = jsonencode({
    source      = ["aws.secretsmanager"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["secretsmanager.amazonaws.com"],
      eventName   = ["PutSecretValue", "UpdateSecret", "UpdateSecretVersionStage"]
      requestParameters = {
        secretId = [aws_secretsmanager_secret.this[0].arn]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "secret_update" {
  count = data.context.sns.enabled ? 1 : 0

  rule      = one(aws_cloudwatch_event_rule.secret_update[*].name)
  arn       = one(aws_sns_topic.secret_update[*].arn)
  target_id = null
}
