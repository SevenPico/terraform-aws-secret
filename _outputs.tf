output "arn" {
  value = try(aws_secretsmanager_secret.this[0].arn, "")
}

output "kms_key_arn" {
  value = try(aws_kms_alias.this[0].target_key_arn, "")
}

output "kms_key_alias_arn" {
  value = try(aws_kms_alias.this[0].arn, "")
}

# output "sns_topic_arn" {
#   value = try(aws_sns_topic.secret_update[0].id, "")
# }
