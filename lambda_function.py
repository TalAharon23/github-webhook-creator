import os
import json
import boto3
import logging

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Retrieve SNS Topic ARN from environment variable
sns_topic_arn = os.environ.get('SNS_TOPIC_ARN', 'default-sns-topic-arn')

# Initialize AWS SDK clients
sns_client = boto3.client('sns')

def lambda_handler(event, context):
    logger.info("Starting analyzing the event payload...")

    try:
        # Parse the JSON body
        body = json.loads(event['body'])
        
        if body['pull_request']['merged']: 
            logger.info("Found a merged PR request.")
            try:
                # Extract information from GitHub webhook payload
                repository_name = body['repository']['full_name']
                pull_request = body['pull_request']
                changed_files = pull_request['head']['repo']['contents_url'].replace('{+path}', '')

                # Log repository name and changed files to CloudWatch Logs
                log_message = f"Repository: {repository_name}, Changed Files: {changed_files}"
                logger.info(log_message)

                # Send SNS notification
                pr_name = pull_request['title']
                sns_subject = f"PR \"{pr_name}\" merged to master successfully"
                sns_body = f"Link to Merged PR: {pull_request['html_url']}"

                sns_response = sns_client.publish(
                    TopicArn=sns_topic_arn,
                    Subject=sns_subject,
                    Message=sns_body,
                    MessageStructure='string'
                )
                logger.info(f"SNS Notification sent: {sns_response}")

                return {
                    'statusCode': 200,
                    'body': json.dumps('Webhook processed successfully')
                }
            except Exception as e:
                logger.error(f"Error processing GitHub webhook event: {e}")
                return {
                    'statusCode': 500,
                    'body': json.dumps('Internal server error')
                }
        else:
            return {
                'statusCode': 400,
                'body': json.dumps('Not a merged PR request!')
            }
    except KeyError as e:
        logger.error(f"Error processing GitHub webhook event: {e}")
        return {
            'statusCode': 400,
            'body': json.dumps(f"Error processing GitHub webhook event: {e}")
        }
