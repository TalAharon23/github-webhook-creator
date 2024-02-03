terraform {
  backend "s3" {
    bucket                  = "github-webhook-statefiles-bucket"
    key                     = "pr-merged-webhook-statefile.tfstate"
    region                  = "us-east-1"
    encrypt                 = true
  }
}

provider "github" {
  token = var.github_token
}

provider "aws" {
  region = var.aws_region
}