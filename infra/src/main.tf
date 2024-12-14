terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

#######################
# IAMロールとポリシー
#######################
resource "aws_iam_role" "lambda_role" {
  name = "example-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "lambda-basic-execution"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#######################
# Lambda関数
#######################
resource "aws_lambda_function" "example_lambda" {
  function_name = "example-lambda"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_role.arn

  filename = "lambda_function_payload.zip"

  source_code_hash = filebase64sha256("lambda_function_payload.zip")
}


#######################
# API Gateway
#######################
# REST API本体
resource "aws_api_gateway_rest_api" "example_api" {
  name        = "example-api"
  description = "Example API Gateway linked with Lambda."
}

# リソースパス（ここでは "/" に GET メソッドをつけるシンプルな例）
resource "aws_api_gateway_resource" "root_resource" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  parent_id   = aws_api_gateway_rest_api.example_api.root_resource_id
  path_part   = "hello"
}

# GETメソッド設定
resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  resource_id   = aws_api_gateway_resource.root_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Lambdaとの統合設定
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.example_api.id
  resource_id             = aws_api_gateway_resource.root_resource.id
  http_method             = aws_api_gateway_method.get_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.example_lambda.invoke_arn
}

# デプロイ
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [aws_api_gateway_integration.lambda_integration]

  rest_api_id = aws_api_gateway_rest_api.example_api.id
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  stage_name    = "dev"
}

# resource "aws_api_gateway_method_settings" "example" {
#   rest_api_id = aws_api_gateway_rest_api.example_api.id
#   stage_name = aws_api_gateway_stage.example.stage_name
#   method_path = "*/*"

#   settings {
#     metrics_enabled = true
#     logging_level = "INFO"
#   }
# }

#######################
# Lambda側でのAPI呼び出し権限設定
#######################
# API GatewayからLambdaをinvokeするためのpermission
resource "aws_lambda_permission" "allow_apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.example_api.execution_arn}/*/*"
}
