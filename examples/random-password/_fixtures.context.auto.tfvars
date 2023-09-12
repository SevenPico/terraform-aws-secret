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
##  ./examples/letsencrypt/_fixtures.context.auto.tfvars
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

enabled   = true
namespace = "sp"
#tenant              =
#project             =
#region              =
environment = "secret"
#stage               =
name = "random-password"
#delimiter           =
#attributes          =
#tags                =
#additional_tag_map  =
#label_order         =
#regex_replace_chars =
#id_length_limit     =
#label_key_case      =
#label_value_case    =
#descriptor_formats  =
#labels_as_tags      =
dns_name_format = "$${name}.$${domain_name}"
domain_name     = "secret-rp.7pi.io"
