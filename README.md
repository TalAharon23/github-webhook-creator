# GitHub Webhook Creator

This project allows you to create and manage GitHub webhooks for Pull Request (PR) merge events using Terraform. It ensures that you can easily set up a webhook service in your AWS environment and integrate it with your GitHub repositories.

## Prerequisites

Before running this project locally, make sure you have the following prerequisites installed and configured:

1. **AWS CLI**: Install and configure the AWS CLI with the necessary permissions to create resources.
2. **GitHub Token**: Generate a GitHub token with the required permissions for creating webhooks. Make sure to keep it secure.

## Local Setup

To run this project locally on your machine, follow these steps:

1. **Clone the Repository:**
    ```bash
    git clone https://github.com/TalAharon23/github-webhook-creator.git
    cd github-webhook-creator

2. **Configure AWS - run the following command:**
    ```bash
    aws configure

3. **Get GitHub Token:**
   - Generate a GitHub token with the required permissions for creating webhooks. You can follow the instructions on the [GitHub documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).

4. **Run Terraform:**
    ```bash
    terraform init
    terraform apply```
    
    After apply, set the Terraform variables used in this project:

| Variable                | Description                                                        | Type   | Default Value   |
| ----------------------- | ------------------------------------------------------------------ | ------ | --------------- |
| `aws_region`            | AWS region to create the GitHub webhook logger services in         | string | `us-east-1`     |
| `github_repo_name`      | GitHub repository name to apply the webhook service on             | string | -               |
| `s3_bucket_backend_name`| S3 bucket where Terraform stores the statefile                     | string | -               |
| `github_token`          | GitHub token for access to create the webhook                      | string | -               |


## Running in Jenkins

Here is example of use after you've successfully configured this self-service in your Jenkins with all AWS and Github credentials there:

