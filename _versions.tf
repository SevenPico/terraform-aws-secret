terraform {
  required_version = ">= 1.0.0"

  required_providers {
    context = {
      source  = "SevenPico/context"
      version = ">= 0.0.3"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

variable "context" {
  type = any
  default = null
}

variable "attributes" {
  type    = list(string)
  default = []
}

data "context" "this" {
  context    = var.context
  attributes = var.attributes
}
