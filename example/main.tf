module "secret" {
  source     = "../"
  attributes = ["example"]

  description                     = "Example Secret"
  block_public_policy             = true
  ignore_secret_changes           = true
  policy_statements               = {}
  recovery_window_in_days         = 7
  secret_read_principals          = {}
  kms_key_deletion_window_in_days = 30
  kms_key_enable_key_rotation     = true
  kms_key_enabled                 = true
  kms_policy_statements           = {}
  secret_string = jsonencode({
    ABC  = 123
    PASS = random_password.example.result
  })
}

resource "random_password" "example" {
  length  = 16
  special = false
}
