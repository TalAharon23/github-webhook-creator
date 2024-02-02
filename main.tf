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

resource "aws_api_gateway_authorizer" "demo" {
  name                   = "apigw-webhook-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.webhook_api.id
  authorizer_uri         = aws_lambda_function.webhook.invoke_arn
  authorizer_credentials = aws_iam_role.invocation_role.arn
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

data "aws_caller_identity" "current" {}

# Allow API Gateway to invoke the Lambda function
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.webhook.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:us-east-1:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.webhook_api.id}/*/${aws_api_gateway_method.webhook_method.http_method}${aws_api_gateway_resource.webhook_resource.path}"
}

# Deploy API Gateway
resource "aws_api_gateway_deployment" "webhook" {
  depends_on = [aws_api_gateway_method.webhook_method, aws_api_gateway_integration.webhook_integration]
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.webhook_api.body))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "apigw_stage" {
  deployment_id = aws_api_gateway_deployment.webhook.id
  rest_api_id   = aws_api_gateway_rest_api.webhook_api.id
  stage_name    = "dev"
}

data "aws_iam_policy_document" "invocation_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "invocation_role" {
  name               = "api_gateway_auth_invocation"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.invocation_assume_role.json
}

data "aws_iam_policy_document" "invocation_policy" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.webhook.arn]
  }
}

resource "aws_iam_role_policy" "invocation_policy" {
  name   = "default"
  role   = aws_iam_role.invocation_role.id
  policy = data.aws_iam_policy_document.invocation_policy.json
}

# GitHub Webhook
resource "github_repository_webhook" "webhook" {
  repository = var.github_repo
  events     = ["pull_request"]

  configuration {
    url          = "${aws_api_gateway_stage.apigw_stage.invoke_url}/${aws_api_gateway_resource.webhook_resource.path_part}"
    content_type = "json"
  }
}

# Lambda Function
resource "aws_lambda_function" "webhook" {
  function_name = "github-webhook"
  runtime       = "python3.8"
  handler       = "lambda_function.lambda_handler"
  filename      = "lambda_function.zip"
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

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda" {
  name = "lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# IAM Policy for Lambda Role
resource "aws_iam_role_policy" "lambda" {
  name   = "lambda-policy"
  role   = aws_iam_role.lambda.id

  # Use the loaded IAM policy
  policy = file("lambda_policy.json")
}

output "api_gateway_invoke_url" {
  value = aws_api_gateway_stage.apigw_stage.invoke_url
}