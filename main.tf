terraform {
  backend "s3" {
    bucket                  = var.s3_bucket_backend_name
    key                     = "github-webhook-statefile.tfstate"
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