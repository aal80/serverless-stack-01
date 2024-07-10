component "cluster" {
  source = "./eks"
  inputs = {
    aws_region          = var.aws_region
    cluster_name_prefix = var.prefix
    instance_type       = "t2.medium"
  }
  providers = {
    aws       = provider.aws.this
    random    = provider.random.this
    tls       = provider.tls.this
    cloudinit = provider.cloudinit.this
} }
