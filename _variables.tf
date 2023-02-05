variable "secret_string" {
  type      = string
  default   = ""
  sensitive = true
}

variable "secret_read_principals" {
  type    = map(any)
  default = {}
}

variable "recovery_window_in_days" {
  type    = number
  default = 7
}

variable "description" {
  type    = string
  default = "It's a secret."
}

variable "block_public_policy" {
  type    = bool
  default = true
}

variable "policy_statements" {
  type    = map(any)
  default = {}
}

variable "ignore_secret_changes" {
  type    = bool
  default = true
}

variable "kms_key_enabled" {
  type    = bool
  default = true
}

variable "kms_key_deletion_window_in_days" {
  type    = number
  default = 30
}

variable "kms_key_enable_key_rotation" {
  type    = bool
  default = true
}

variable "kms_policy_statements" {
  type    = map(any)
  default = {}
}

variable "sns_enabled" {
  type    = bool
  default = false
}

variable "sns_pub_principals" {
  type    = map(any)
  default = {}
}

variable "sns_sub_principals" {
  type    = map(any)
  default = {}
}
