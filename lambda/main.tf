data "archive_file" "function_zip" {
  type = "zip"
  source_dir  = "${path.module}/../src"
  output_path = "${path.module}/../../../tmp/function.zip"
}

resource "random_pet" "function_name" {
  prefix = "lambda-"
  length = 3
}

resource "aws_iam_role" "exec_role" {
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

 resource "aws_iam_role_policy_attachment" "basic_exec_role" {
   role       = aws_iam_role.exec_role.name
   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
 }

 resource "aws_lambda_function" "this" {
   function_name = random_pet.function_name.id
   role = aws_iam_role.exec_role.arn

   runtime = "nodejs20.x"
   handler = "index.handler"

   filename = data.archive_file.function_zip.output_path
   source_code_hash = data.archive_file.function_zip.output_base64sha256
 }

 resource "aws_cloudwatch_log_group" "hello_world" {
   name = "/aws/lambda/${aws_lambda_function.this.function_name}"

   retention_in_days = 30
 }

output "function_name" {
   description = "Name of the Lambda function."
   value = aws_lambda_function.this.function_name
}

output "invoke_arn" {
  description = "The invocation ARN of the function"
  value = aws_lambda_function.this.invoke_arn
}
