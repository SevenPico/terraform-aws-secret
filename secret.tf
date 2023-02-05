# ------------------------------------------------------------------------------
# Secret
# ------------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "this" {
  count = data.context.this.enabled ? 1 : 0

  name_prefix             = "${data.context.this.name}${data.context.this.descriptors.name.delimiter}"
  tags                    = data.context.this.tags
  name                    = null
  description             = var.description
  kms_key_id              = data.context.kms.enabled ? aws_kms_key.this[0].key_id : null
  policy                  = null # managed with aws_secretsmanager_secret_policy resource
  recovery_window_in_days = var.recovery_window_in_days

  # TODO
  # replica {}
  # force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "default" {
  count = data.context.this.enabled && !var.ignore_secret_changes ? 1 : 0

  secret_id     = aws_secretsmanager_secret.this[0].id
  secret_string = var.secret_string

  lifecycle {
    ignore_changes = [secret_string, secret_binary]
  }
}

resource "aws_secretsmanager_secret_version" "no_ignore_changes" {
  count = data.context.this.enabled && var.ignore_secret_changes ? 1 : 0

  secret_id     = aws_secretsmanager_secret.this[0].id
  secret_string = var.secret_string
}


# ------------------------------------------------------------------------------
# Secret Policy
# ------------------------------------------------------------------------------
resource "aws_secretsmanager_secret_policy" "this" {
  count = data.context.this.enabled ? 1 : 0

  secret_arn          = aws_secretsmanager_secret.this[0].arn
  block_public_policy = true
  policy              = module.secret_policy.json
}

module "secret_policy" {
  source  = "app.terraform.io/SevenPico/iam/aws//modules/policy"
  version = "0.0.4"
  context = data.context.this

  description                   = null
  iam_override_policy_documents = null
  iam_policy_enabled            = false
  iam_policy_id                 = null
  iam_source_json_url           = null
  iam_source_policy_documents   = null
  iam_policy_statements = merge({
    default = {
      effect    = "Allow"
      resources = ["*"]
      principals = concat([{
        type        = "AWS"
        identifiers = [data.aws_caller_identity.current.account_id]
        }],
        [
          for pk, pv in var.secret_read_principals : {
            type        = pk
            identifiers = pv
          }
      ])
      actions = [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ]
      conditions = []
    }
  }, var.policy_statements)
}


# ------------------------------------------------------------------------------
# Secret Rotation
# ------------------------------------------------------------------------------
# TODO
# resource "aws_secretsmanager_secret_rotation" "this" {
#   secret_id           = aws_secretsmanager_secret.this.id
#   rotation_lambda_arn = aws_lambda_function.rotation.arn

#   rotation_rules {
#     automatically_after_days = var.rotation_period_in_days
#   }
# }
