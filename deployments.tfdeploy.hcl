identity_token "aws" {
  audience = ["aws.workload.identity"]
}

deployment "development" {
  inputs = {
    regions        = ["us-east-1"]
    role_arn       = "arn:aws:iam::609845769455:role/tfc-stack-developer"
    identity_token = identity_token.aws.jwt
    default_tags   = { stack = "lambda-demo-stack" }
  }
}
