output "gateway_url" {
  description = "The Gateway URL for API Gateway"
  value       = "${aws_apigatewayv2_api.gateway.api_endpoint}/${module.common.normalized_api_path}"
}

output "api_id" {
  description = "The ID of the API Gateway"
  value       = aws_apigatewayv2_api.gateway.id
}

output "api_arn" {
  description = "The ARN of the API Gateway"
  value       = aws_apigatewayv2_api.gateway.arn
}

output "authorizer_function_name" {
  description = "The name of the Lambda authorizer function"
  value       = aws_lambda_function.authorizer.function_name
}

output "authorizer_function_arn" {
  description = "The ARN of the Lambda authorizer function"
  value       = aws_lambda_function.authorizer.arn
}
