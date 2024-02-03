provider "github" {
  token = var.github_token
}

provider "aws" {
  region = var.aws_region
}