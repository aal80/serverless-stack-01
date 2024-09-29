component "s3" {
  for_each = var.regions

  source = "./s3"

  inputs = {
    region = each.value
  }

  providers = {
    aws    = provider.aws.configurations[each.value]
    random = provider.random.this
  }
}
