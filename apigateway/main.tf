variable "lambda_function_name" {
  type = string
}

variable "lambda_invoke_arn" {
  type = string
}

resource "random_pet" "apigateway_name" {
  prefix = "apigw"
  length = 2
}

 resource "aws_apigatewayv2_api" "this" {
   name          = random_pet.apigateway_name.id
   protocol_type = "HTTP"
 }

 resource "aws_apigatewayv2_stage" "this" {
   api_id = aws_apigatewayv2_api.lambda.id

   name        = "api"
   auto_deploy = true

   access_log_settings {
     destination_arn = aws_cloudwatch_log_group.api_gw.arn

     format = jsonencode({
       requestId               = "$context.requestId"
       sourceIp                = "$context.identity.sourceIp"
       requestTime             = "$context.requestTime"
       protocol                = "$context.protocol"
       httpMethod              = "$context.httpMethod"
       resourcePath            = "$context.resourcePath"
       routeKey                = "$context.routeKey"
       status                  = "$context.status"
       responseLength          = "$context.responseLength"
       integrationErrorMessage = "$context.integrationErrorMessage"
       }
     )
   }
 }

 resource "aws_apigatewayv2_integration" "this" {
   api_id = aws_apigatewayv2_api.this.id

   integration_uri    = var.lambda_invoke_arn
   integration_type   = "AWS_PROXY"
   integration_method = "POST"
 }

 resource "aws_apigatewayv2_route" "this" {
   api_id = aws_apigatewayv2_api.this.id

   route_key = "GET /hello1"
   target    = "integrations/${aws_apigatewayv2_integration.this.id}"
 }

 resource "aws_cloudwatch_log_group" "this" {
   name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"
   retention_in_days = 30
 }

 resource "aws_lambda_permission" "this" {
   statement_id  = "AllowExecutionFromAPIGateway"
   action        = "lambda:InvokeFunction"
   function_name = var.lambda_function_name
   principal     = "apigateway.amazonaws.com"
   source_arn = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
 }

output "endpoint_url" {
   value = aws_apigatewayv2_stage.this.invoke_url
}
