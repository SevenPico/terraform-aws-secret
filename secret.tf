# ------------------------------------------------------------------------------
# Secret Meta
# ------------------------------------------------------------------------------
module "secret_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  enabled    = module.this.enabled
  attributes = ["secret"]
}

module "secret_kms_key_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.secret_meta.context
  attributes = ["kms", "key"]
}

data "aws_caller_identity" "current" {}


# ------------------------------------------------------------------------------
# KMS Key
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "kms_key_access_policy_doc" {
  count = module.this.enabled && length(var.secret_read_principals) == 0 ? 0 : 1

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
      sid = "Allow secret decrypt"
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

resource "aws_kms_key" "this" {
  count = module.secret_kms_key_meta.enabled ? 1 : 0

  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 30
  description              = "KMS key for ${module.this.id}"
  enable_key_rotation      = false
  key_usage                = "ENCRYPT_DECRYPT"
  policy                   = one(data.aws_iam_policy_document.kms_key_access_policy_doc[*].json)
  tags                     = module.secret_kms_key_meta.tags
}

resource "aws_kms_alias" "this" {
  count = module.secret_kms_key_meta.enabled ? 1 : 0

  name          = module.this.id != "" ? format("alias/%v", module.this.id) : null
  name_prefix   = module.this.id != "" ? null : "alias/${aws_kms_key.key_id}"
  target_key_id = one(aws_kms_key.this[*].id)
}


# ------------------------------------------------------------------------------
# Secret
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "secret_access_policy_doc" {
  count = module.this.enabled && length(var.secret_read_principals) == 0 ? 0 : 1

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
  count = module.secret_meta.enabled ? 1 : 0

  description = var.description
  kms_key_id  = one(aws_kms_key.this[*].key_id)
  name_prefix = "${module.secret_meta.id}-"
  policy      = one(data.aws_iam_policy_document.secret_access_policy_doc[*].json)
  tags        = module.secret_meta.tags
}

resource "aws_secretsmanager_secret_version" "default" {
  count = (module.secret_meta.enabled && !var.secret_ignore_changes) ? 1 : 0

  secret_id     = one(aws_secretsmanager_secret.this[*].id)
  secret_string = var.secret_string
}

resource "aws_secretsmanager_secret_version" "ignore_changes" {
  count = (module.secret_meta.enabled && var.secret_ignore_changes) ? 1 : 0

  secret_id     = one(aws_secretsmanager_secret.this[*].id)
  secret_string = var.secret_string

  lifecycle {
    ignore_changes = [secret_string, secret_binary]
  }
}
