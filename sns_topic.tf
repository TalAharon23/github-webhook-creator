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

