resource "random_pet" "function_name" {
  prefix = "lambda-"
  length = 3
}

data "archive_file" "this" {
  type = "zip"
  source_dir  = "${path.module}/../src"
  output_path = "${path.module}/../../../tmp/${random_pet.function_name}.zip"
}


data "local_file" "this" {
  filename = data.archive_file.this.output_path
}

resource "aws_s3_object" "this" {
  bucket = var.bucket_id

  key    = "${random_pet.function_name}.zip"

  content_base64 = data.local_file.this.content_base64
  # source = data.archive_file.lambda_hello_world.output_path

  etag = data.local_file.this.content_md5
  # etag = filemd5(data.archive_file.lambda_hello_world.output_path)
}

resource "aws_iam_role" "this" {
   name = random_pet.function_name.id

   assume_role_policy = jsonencode({
     Version = "2012-10-17"
     Statement = [{
       Action = "sts:AssumeRole"
       Effect = "Allow"
       Sid    = ""
       Principal = {
         Service = "lambda.amazonaws.com"
       }
       }
     ]
   })
 }

 resource "aws_iam_role_policy_attachment" "this" {
   role       = aws_iam_role.this.name
   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
 }

 resource "aws_lambda_function" "this" {
   function_name = random_pet.function_name.id
   role = aws_iam_role.this.arn

   runtime = "nodejs18.x"
   handler = "index.handler"

   s3_bucket = var.bucket_id
   s3_key    = aws_s3_object.this.key

    source_code_hash = data.archive_file.this.output_base64sha256
 }

 resource "aws_cloudwatch_log_group" "this" {
   name = "/aws/lambda/${aws_lambda_function.this.function_name}"

   retention_in_days = 30
 }

output "function_name" {
   value = aws_lambda_function.this.function_name
}

output "invoke_arn" {
  value = aws_lambda_function.this.invoke_arn
}
