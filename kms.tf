# ------------------------------------------------------------------------------
# KMS Key
# ------------------------------------------------------------------------------
data "context" "kms" {
  context = data.context.this
  enabled = var.kms_key_enabled
}

resource "aws_kms_key" "this" {
  count = data.context.kms.enabled ? 1 : 0

  bypass_policy_lockout_safety_check = false
  customer_master_key_spec           = "SYMMETRIC_DEFAULT"
  deletion_window_in_days            = var.kms_key_deletion_window_in_days
  description                        = "KMS Key for Secret: ${data.context.this.name}"
  enable_key_rotation                = var.kms_key_enable_key_rotation
  is_enabled                         = true
  key_usage                          = "ENCRYPT_DECRYPT"
  multi_region                       = false
  policy                             = module.kms_policy.json
  tags                               = data.context.kms.tags
}

resource "aws_kms_alias" "this" {
  count = data.context.kms.enabled ? 1 : 0

  name          = "alias/${data.context.kms.name}"
  target_key_id = aws_kms_key.this[0].id
  name_prefix   = null # don't use
}

module "kms_policy" {
  source  = "app.terraform.io/SevenPico/iam/aws//modules/policy"
  version = "0.0.4"
  context = data.context.kms

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
      principals = [{
        type        = "AWS"
        identifiers = [data.aws_caller_identity.current.account_id]
      }]
      actions = [
        "kms:*",
      ]
      conditions = []
    }
    read = {
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
        "kms:Decrypt",
      ]
      conditions = []
    }
  }, var.kms_policy_statements)
}
