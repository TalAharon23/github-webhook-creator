# GitHub Webhook
resource "github_repository_webhook" "webhook" {
  repository = var.github_repo_name
  events     = ["pull_request"]

  configuration {
    url          = "${aws_api_gateway_stage.apigw_stage.invoke_url}/${aws_api_gateway_resource.webhook_resource.path_part}"
    content_type = "json"
  }
}