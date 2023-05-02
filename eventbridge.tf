# ------------------------------------------------------------------------------
#  Secret Update CloudWatch Event to SNS
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "secret_update" {
  count = module.sns_event_context.enabled ? 1 : 0

  description = "Event on change of secret value"
  name        = "${module.sns_event_context.id}-rule"
  is_enabled  = true
  tags        = module.context.tags

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
