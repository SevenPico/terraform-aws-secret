resource "random_password" "password" {
  count = module.context.enabled ? 1 : 0

  length           = var.password_length
  keepers          = var.password_keepers
  lower            = var.password_include_lower
  min_lower        = var.password_min_lower
  min_numeric      = var.password_min_numeric
  min_special      = var.password_min_special
  min_upper        = var.password_min_upper
  override_special = var.password_override_special
  special          = var.password_include_special
  upper            = var.password_include_upper
}
