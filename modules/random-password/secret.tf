locals {
  secrets = {
    "${var.keyname_password}" = join("", random_password.password.*.result)
  }

}

module "secret" {
  source  = "../../"
  context = module.context.self


  description                     = var.description
  create_sns                      = var.create_sns
  kms_key_deletion_window_in_days = var.kms_key_deletion_window_in_days
  kms_key_enable_key_rotation     = var.kms_key_enable_key_rotation
  secret_ignore_changes           = var.secret_ignore_changes
  secret_read_principals          = var.secret_read_principals
  secret_string                   = jsonencode(merge(local.secrets, var.additional_secrets))
  sns_pub_principals              = var.sns_pub_principals
  sns_sub_principals              = var.sns_sub_principals
}
