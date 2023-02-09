output "arn" {
  value = one(aws_secretsmanager_secret.this[*].arn)
}

output "kms_key_arn" {
  value = module.kms_key.key_arn
}

output "kms_key_alias_name" {
  value = module.kms_key.alias_name
}

output "kms_key_alias_arn" {
  value = module.kms_key.alias_arn
}

output "sns_topic_arn" {
  value = one(aws_sns_topic.secret_update[*].id)
}
