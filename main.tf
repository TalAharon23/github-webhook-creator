provider "github" {
  token = var.github_token
}

provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket                  = "github-webhook-statefiles-bucket"
    key                     = "github-webhook-statefile.tfstate"
    region                  = "us-east-1"
    encrypt                 = true
  }
}