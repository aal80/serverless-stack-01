deployment "development" {
  variables = {
    prefix           = "dev"
  }
}

deployment "production" {
  variables = {
    prefix           = "prod"
  }
}
