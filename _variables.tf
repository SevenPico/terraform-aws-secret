variable "secret_string" {
  type    = string
  default = ""
}

variable "description" {
  type    = string
  default = ""
}

variable "kms_key_deletion_window_in_days" {
  type    = number
  default = 30
}

variable "kms_key_enable_key_rotation" {
  type    = bool
  default = true
}

variable "secret_read_principals" {
  type    = map(any)
  default = {}
}

variable "secret_ignore_changes" {
  type    = bool
  default = false
}

variable "create_sns" {
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

variable "organization_id" {
  type    = string
  default = ""
}
