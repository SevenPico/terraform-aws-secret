output "arn" {
  value = one(aws_secretsmanager_secret.this[*].arn)
}

output "kms_key_arn" {
  value = one(aws_kms_key.this[*].arn)
}

output "kms_key_alias_name" {
  value = one(aws_kms_alias.this[*].name)
}

output "kms_key_alias_arn" {
  value = one(aws_kms_alias.this[*].arn)
}

output "sns_topic_arn" {
  value = one(aws_sns_topic.secret_update[*].id)
}
