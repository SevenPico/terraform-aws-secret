
variable "secret_string" {
  type = string
  default = ""
}

variable "description" {
  type = string
  default = ""
}

variable "secret_read_principals" {
  type = list(number)
  default = []
}

variable "secret_ignore_changes" {
  description = "Add ignore_change on SecretsManager secret values to allow later replacement of the secret"
  type = bool
  default = false
}

variable "create_secret_update_sns" {
  type    = bool
  default = false
}

variable "secret_update_sns_pub_principals" {
  type    = map(any)
  default = {}
}

variable "secret_update_sns_sub_principals" {
  type    = map(any)
  default = {}
}

