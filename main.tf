provider "github" {
  # Configure GitHub provider
  token = "your-github-token"
}

provider "aws" {
  # Configure AWS provider
  region = "us-east-1"
}

# GitHub Webhook
resource "github_repository_webhook" "webhook" {
  repository = var.github_repo
  name       = "web"
  events     = ["pull_request"]

  configuration = {
    url          = aws_lambda_function.webhook.invoke_arn
    content_type = "json"
  }
}

# Lambda Function
resource "aws_lambda_function" "webhook" {
  function_name = "github-webhook"
  runtime       = "python3.8"
  handler       = "lambda_function.lambda_handler"
  filename      = "path/to/your/lambda/zip/file.zip"  # Package your Lambda function

  role = aws_iam_role.lambda.arn

  # Additional Lambda configuration like environment variables, etc.
}

# SNS Topic
resource "aws_sns_topic" "github_webhook_topic" {
  name = "github-webhook-topic"
}

# SNS Subscription
resource "aws_sns_topic_subscription" "github_webhook_subscription" {
  topic_arn = aws_sns_topic.github_webhook_topic.arn
  protocol  = "email"
  endpoint  = "tal.aharon97@gmail.com"
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

# IAM Policy for Lambda Role
resource "aws_iam_role_policy" "lambda" {
  name   = "lambda-policy"
  role   = aws_iam_role.lambda.id

  # Define the necessary policies for GitHub, CloudWatch Logs, and SNS
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "github:Get*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sns:Publish",
        "sns:ListTopics"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}