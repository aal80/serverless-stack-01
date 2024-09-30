resource "aws_s3_bucket" "lambda_code_storage" {
  bucket_prefix = "lambda-code-storage"
}

resource "aws_s3_bucket_ownership_controls" "bucket_controls" {
  bucket = aws_s3_bucket.lambda_code_storage.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket_controls]

  bucket = aws_s3_bucket.lambda_code_storage.id
  acl    = "private"
}

output "bucket_id" {
  description = "The ID of the S3 bucket to be used by a downstream component in this stack."
  value = aws_s3_bucket.lambda_code_storage.id
}

