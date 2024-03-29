variable "aws_region" {
  description = "The AWS region to create all Github webhook logger services in"
  type = string
  default = "us-east-1"
}

variable "github_repo_name" {
  description = "Github repository name to apply the webhook service on"
  type = string
}

variable "email_subscriber" {
  description = "Which Email endpoint should get notified when webhook triggred?"
  type = string
}

variable "github_token" {
  description = "Github token for access to create the webhook"
  type = string
}