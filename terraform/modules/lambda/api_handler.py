import json
import boto3
import os

# Create SQS client
sqs = boto3.client("sqs")
queue_url = os.environ["QUEUE_URL"]

def lambda_handler(event, context):
    """
    Handles HTTP requests from API Gateway and sends message to SQS
    """

    try:
        # Parse JSON body from HTTP POST
        body = json.loads(event['body'])
        message = body.get("message", "default message")

        # Send message to SQS
        sqs.send_message(
            QueueUrl=queue_url,
            MessageBody=message
        )

        return {
            "statusCode": 200,
            "body": json.dumps({"status": "Message sent", "message": message})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }