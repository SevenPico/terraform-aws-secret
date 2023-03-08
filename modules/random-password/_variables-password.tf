variable "password_length" {
  type        = number
  description = "The length of the string desired.The minimum value for length is 1 and, length must also be >= (min_upper + min_lower + min_numeric + min_special)."
}

variable "password_keepers" {
  type        = map(string)
  description = "Arbitrary map of values that, when changed, will trigger recreation of resource. See the main provider documentation for more information."
  default     = null
}

variable "password_include_lower" {
  type        = bool
  description = "Include lowercase alphabet characters in the result. Default value is true."
  default     = true
}

variable "password_min_lower" {
  type        = number
  description = "Minimum number of lowercase alphabet characters in the result. Default value is 0."
  default     = 0
}

variable "password_min_numeric" {
  type        = number
  description = "Minimum number of numeric characters in the result. Default value is 0."
  default     = 0
}

variable "password_min_special" {
  type        = number
  description = "Minimum number of special characters in the result. Default value is 0."
  default     = 0
}
variable "password_min_upper" {
  type        = number
  description = "Minimum number of uppercase alphabet characters in the result. Default value is 0."
  default     = 0
}

variable "password_numeric" {
  type        = bool
  description = "Include numeric characters in the result. Default value is true."
  default     = true
}

variable "password_override_special" {
  type        = string
  description = "Supply your own list of special characters to use for string generation. This overrides the default character list in the special argument. The special argument must still be set to true for any overwritten characters to be used in generation."
  default     = null
}

variable "password_include_special" {
  type        = bool
  description = "Include special characters in the result. These are !@#$%&*()-_=+[]{}<>:?. Default value is true."
  default     = true
}

variable "password_include_upper" {
  type        = bool
  description = "Include uppercase alphabet characters in the result. Default value is true."
  default     = true
}

variable "keyname_password" {
  type = string
  description = "The keyname to use for the password value stored in the secret string."
  default = "PASSWORD"
}

variable "additional_secrets" {
  description = "Additional key-value pairs to add to the created SecretsManager secret"
  type        = map(any)
  default     = {}
}
