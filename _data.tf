# The AWS region currently being used.
data "aws_region" "current" {
}

# The AWS account id
data "aws_caller_identity" "current" {
}

# The AWS partition (commercial or govcloud)
data "aws_partition" "current" {
}

locals {
  arn_prefix = "arn:${data.aws_partition.current.partition}"
  arn_template = "${local.arn_prefix}:%s:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}%s"
}
