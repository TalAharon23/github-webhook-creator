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
  name = "github-webhook-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# IAM Policy for Lambda Role
resource "aws_iam_role_policy" "lambda" {
  name   = "github-webhook-lambda-policy"
  role   = aws_iam_role.lambda.id

  # Use the loaded IAM policy
  policy = file("lambda_policy.json")
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