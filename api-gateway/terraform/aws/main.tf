# Common module for shared values
module "common" {
  source = "../modules/common"
  
  environment         = var.environment
  region              = var.region
  cloud_provider      = "aws"
  backend_service_url = var.backend_service_url
  oidc_audience       = var.oidc_audience
}

# Lambda Function for OIDC JWT Validation
data "archive_file" "authorizer_lambda" {
  type        = "zip"
  output_path = "${path.module}/lambda_authorizer.zip"
  
  source {
    content  = file("${path.module}/lambda/authorizer.py")
    filename = "authorizer.py"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "authorizer_lambda" {
  name = "github-oidc-authorizer-${var.environment}-${module.common.random_suffix}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = module.common.common_tags
}

# IAM Policy for Lambda Logging
resource "aws_iam_role_policy_attachment" "authorizer_lambda_logs" {
  role       = aws_iam_role.authorizer_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "authorizer" {
  filename         = data.archive_file.authorizer_lambda.output_path
  function_name    = "github-oidc-authorizer-${var.environment}-${module.common.random_suffix}"
  role            = aws_iam_role.authorizer_lambda.arn
  handler         = "authorizer.lambda_handler"
  source_code_hash = data.archive_file.authorizer_lambda.output_base64sha256
  runtime         = "python3.12"
  timeout         = 30

  environment {
    variables = {
      GITHUB_ORG       = module.common.github_org
      GITHUB_REPO      = module.common.github_repo
      OIDC_AUDIENCE    = module.common.oidc_audience
    }
  }

  tags = module.common.common_tags
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "authorizer" {
  name              = "/aws/lambda/${aws_lambda_function.authorizer.function_name}"
  retention_in_days = 7

  tags = module.common.common_tags
}

# API Gateway v2 (HTTP API)
resource "aws_apigatewayv2_api" "gateway" {
  name          = "github-actions-gateway-${var.environment}-${module.common.random_suffix}"
  protocol_type = "HTTP"
  description   = "API Gateway for GitHub Actions to access private resources using OIDC authentication"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["*"]
  }

  tags = module.common.common_tags
}

# Lambda Authorizer
resource "aws_apigatewayv2_authorizer" "github_oidc" {
  api_id           = aws_apigatewayv2_api.gateway.id
  authorizer_type  = "REQUEST"
  authorizer_uri   = aws_lambda_function.authorizer.invoke_arn
  identity_sources = ["$request.header.Authorization"]
  name             = "github-oidc-authorizer"
  authorizer_payload_format_version = "2.0"
  enable_simple_responses           = true
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.gateway.execution_arn}/*"
}

# VPC Link (if using private backend)
resource "aws_apigatewayv2_vpc_link" "private" {
  count              = var.vpc_id != "" ? 1 : 0
  name               = "github-actions-vpclink-${var.environment}"
  security_group_ids = [var.security_group_id]
  subnet_ids         = var.subnet_ids

  tags = module.common.common_tags
}

# Integration with Backend
resource "aws_apigatewayv2_integration" "backend" {
  api_id           = aws_apigatewayv2_api.gateway.id
  integration_type = var.vpc_id != "" ? "HTTP_PROXY" : "HTTP_PROXY"
  integration_uri  = module.common.backend_service_url
  integration_method = "ANY"
  
  dynamic "tls_config" {
    for_each = var.vpc_id == "" ? [1] : []
    content {
      server_name_to_verify = regex("https://([^/]+)", module.common.backend_service_url)[0]
    }
  }

  connection_type = var.vpc_id != "" ? "VPC_LINK" : "INTERNET"
  connection_id   = var.vpc_id != "" ? aws_apigatewayv2_vpc_link.private[0].id : null
}

# Route: Catch-all with Authorization
resource "aws_apigatewayv2_route" "proxy" {
  api_id    = aws_apigatewayv2_api.gateway.id
  route_key = "ANY /${module.common.normalized_api_path}/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.backend.id}"
  
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.github_oidc.id
}

# Stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.gateway.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  tags = module.common.common_tags
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${aws_apigatewayv2_api.gateway.name}"
  retention_in_days = 7

  tags = module.common.common_tags
}
