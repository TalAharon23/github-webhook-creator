import os
import json
import requests
import boto3
import logging

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS SDK clients
cloudwatch_logs = boto3.client('logs')
sns_client = boto3.client('sns')

def lambda_handler(event, context):
    try:
        # Extract information from GitHub webhook payload
        repository_name = event['repository']['full_name']
        pull_request = event['pull_request']
        changed_files = pull_request['head']['repo']['contents_url'].replace('{+path}', '')

        # Log repository name and changed files to CloudWatch Logs
        log_message = f"Repository: {repository_name}, Changed Files: {changed_files}"
        logger.info(log_message)

        # Send SNS notification
        pr_name = pull_request['title']
        sns_subject = f"PR \"{pr_name}\" merged to master successfully"
        sns_body = f"Link to Merged PR: {pull_request['html_url']}"

        sns_response = sns_client.publish(
            TopicArn='your-sns-topic-arn',
            Subject=sns_subject,
            Message=sns_body,
            MessageStructure='string'
        )
        logger.info(f"SNS Notification sent: {sns_response}")

    except Exception as e:
        logger.error(f"Error processing GitHub webhook event: {e}")

    return {
        'statusCode': 200,
        'body': json.dumps('Webhook processed successfully')
    }
