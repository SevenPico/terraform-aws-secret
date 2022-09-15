plugin "terraform" {
  enabled = true
  preset  = "recommended" # "all"
}

plugin "aws" {
    enabled = true
    version = "0.17.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "terraform_comment_syntax" {
  enabled = true
}
