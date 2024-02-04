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
    terraform apply
    
After apply, set the Terraform variables used in this project:

| Variable                | Description                                                        | Type   | Default Value   |
| ----------------------- | ------------------------------------------------------------------ | ------ | --------------- |
| `aws_region`            | AWS region to create the GitHub webhook logger services in         | string | `us-east-1`     |
| `github_repo_name`      | GitHub repository name to apply the webhook service on             | string | -               |
| `email_subscriber`      | Which Email endpoint should get notified when webhook triggred?    | string | -               |
| `github_token`          | GitHub token for access to create the webhook                      | string | -               |


## Running in Jenkins

Here is an example of use after you've successfully configured this self-service in your Jenkins with all AWS and Github credentials there:

After setting up the Jenkins self-service, it will look like this. To start running the self-service and creating a Github webhook on a Github repo, click on the "Build with Parameters"
![image](https://github.com/TalAharon23/github-webhook-creator/assets/82831070/d088854b-13ad-4cf1-a422-cceb5b342363)

Then, set the service variables based on the above Terraform variables mentioned before. Choose whether to create the Github webhook or destroy it.
![image](https://github.com/TalAharon23/github-webhook-creator/assets/82831070/72eef650-8c5a-463d-8a55-515f22dc10aa)

Click on Build and all the magic will happen 😊

## Review the changes
### After everything was set up you will see at the Github repo the new webhook that was created. And after a merged PR you will get an email notification with a link to the PR changes (Don't forget approve the email subscription).

New Webhook:
![image](https://github.com/TalAharon23/github-webhook-creator/assets/82831070/9697f555-1bd2-48a1-9178-3454ddce7244)

Example of email:
![image](https://github.com/TalAharon23/github-webhook-creator/assets/82831070/f727ee7c-97a9-4347-9fb4-0e9b791d48e9)



