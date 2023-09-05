## ----------------------------------------------------------------------------
##  Copyright 2023 SevenPico, Inc.
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------
##  ./_variables.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

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

variable "secret_ignore_changes" {
  type    = bool
  default = false
}

variable "create_sns" {
  type    = bool
  default = false
}

variable "secret_read_principals" {
  type = map(object({
    type        = string
    identifiers = list(string)
    condition   = any
  }))
  default     = {}
  description = <<EOF
The following example input Allows for the specification of Principals as well as Principals with Conditions.
If no Conditions are needed, the Condition block can be set to null, but that needs to be consistent for each map item
{
    RootAccess = {
      type = "AWS"
      identifiers = [var.principal_account_id]
      condition = {
        test     = null
        values   = []
        variable =
      }
    },
    PubConditional = {
      type = "AWS"
      identifiers = ["*"]
      condition = {
        test     = "ForAnyValue:StringLike"
        values   = [var.organization_ou_id]
        variable = "aws:PrincipalOrgPaths"
      }
    }
}
EOF
}

variable "sns_pub_principals" {
  type = map(object({
    type        = string
    identifiers = list(string)
    condition   = any
  }))
  default     = {}
  description = <<EOF
The following example input Allows for the specification of Principals as well as Principals with Conditions.
If no Conditions are needed, the Condition block can be set to null, but that needs to be consistent for each map item
{
    RootAccess = {
      type = "AWS"
      identifiers = [var.principal_account_id]
      condition = {
        test     = null
        values   = []
        variable =
      }
    },
    PubConditional = {
      type = "AWS"
      identifiers = ["*"]
      condition = {
        test     = "ForAnyValue:StringLike"
        values   = [var.organization_ou_id]
        variable = "aws:PrincipalOrgPaths"
      }
    }
}
EOF
}

variable "sns_sub_principals" {
  type = map(object({
    type        = string
    identifiers = list(string)
    condition   = any
  }))
  default     = {}
  description = <<EOF
The following example input Allows for the specification of Principals as well as Principals with Conditions.
If no Conditions are needed, the Condition block can be set to null, but that needs to be consistent for each map item
{
    RootAccess = {
      type = "AWS"
      identifiers = [var.principal_account_id]
      condition = {
        test     = null
        values   = []
        variable =
      }
    },
    PubConditional = {
      type = "AWS"
      identifiers = ["*"]
      condition = {
        test     = "ForAnyValue:StringLike"
        values   = [var.organization_ou_id]
        variable = "aws:PrincipalOrgPaths"
      }
    }
}
EOF
}

variable "kms_key_multi_region" {
  type        = bool
  default     = false
  description = "Indicates whether the KMS key is a multi-Region (true) or regional (false) key."
}

variable "replica_regions" {
  type        = list(string)
  default     = []
  description = "The list of regions to replicate to."
}

variable "kms_key_enabled" {
  type = bool
  default = true
  description = "When this set to false a value must be put into kms_key_id"
}

variable "kms_key_id" {
  type = string
  default = null
}

