provider "github" {
  # Configure GitHub provider
  token = "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"
}

provider "aws" {
  # Configure AWS provider
  region = "us-east-1"
}

# Create API Gateway
resource "aws_api_gateway_rest_api" "webhook_api" {
  name        = "webhook-api"
  description = "API Gateway for GitHub webhook"
}

resource "aws_api_gateway_resource" "webhook_resource" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id
  parent_id   = aws_api_gateway_rest_api.webhook_api.root_resource_id
  path_part   = "webhook"
}

resource "aws_api_gateway_method" "webhook_method" {
  rest_api_id   = aws_api_gateway_rest_api.webhook_api.id
  resource_id   = aws_api_gateway_resource.webhook_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "webhook_integration" {
  rest_api_id             = aws_api_gateway_rest_api.webhook_api.id
  resource_id             = aws_api_gateway_resource.webhook_resource.id
  http_method             = aws_api_gateway_method.webhook_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.webhook.invoke_arn
}

# Deploy API Gateway
resource "aws_api_gateway_deployment" "webhook" {
  depends_on = [aws_api_gateway_integration.webhook_integration]
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id
  stage_name  = "prod"
}

# GitHub Webhook
resource "github_repository" "repo" {
  name         = "gh-pr-logger-repo"
  description  = "Github repository to enable webhook on"
  homepage_url = "https://github.com/TalAharon23/${var.github_repo}"

  visibility   = "private"
}

resource "github_repository_webhook" "webhook" {
  repository = github_repository.repo.name
  events     = ["pull_request"]

  configuration {
    url          = aws_api_gateway_deployment.webhook.invoke_url
    content_type = "json"
  }
}

# Lambda Function
resource "aws_lambda_function" "webhook" {
  function_name = "github-webhook"
  runtime       = "python3.8"
  handler       = "lambda_function.lambda_handler"
  filename      = "lambda_handler.zip"

  role = aws_iam_role.lambda.arn

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.github_webhook_topic.arn
    }
  }
}

# SNS Topic
resource "aws_sns_topic" "github_webhook_topic" {
  name = "github-webhook-topic"
}

# SNS Subscription
resource "aws_sns_topic_subscription" "github_webhook_subscription" {
  topic_arn = aws_sns_topic.github_webhook_topic.arn
  protocol  = "email"
  endpoint  = "dsaptal@gmail.com"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com",
      },
    }],
  })
}

# # IAM Policy for Lambda Role
# data "aws_iam_policy_document" "lambda" {
#   source = file("lambda_policy.json")
# }

# IAM Policy for Lambda Role
resource "aws_iam_role_policy" "lambda" {
  name   = "lambda-policy"
  role   = aws_iam_role.lambda.id

  # Use the loaded IAM policy
  policy = file("lambda_policy.json")
  # policy = data.aws_iam_policy_document.lambda.json
}