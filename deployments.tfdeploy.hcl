identity_token "aws" {
  audience = ["aws.workload.identity"]
}

deployment "development" {
  inputs = {
    regions        = ["us-east-1"]
    role_arn       = "arn:aws:iam::281024298475:role/terraform-cloud-role"
    identity_token = identity_token.aws.jwt
    default_tags   = { 
      stack = "lambda-demo-stack" 
      environment = "development"
    }
  }

deployment "production" {
  inputs = {
    regions        = ["us-east-1", "us-west-1"]
    role_arn       = "arn:aws:iam::281024298475:role/terraform-cloud-role"
    identity_token = identity_token.aws.jwt
    default_tags   = { 
      stack = "lambda-demo-stack" 
      environment = "production"
    }
  }
}
