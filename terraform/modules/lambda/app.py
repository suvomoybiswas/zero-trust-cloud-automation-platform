import json
import os
import boto3
import uuid

# AWS clients
dynamodb = boto3.resource("dynamodb")
s3 = boto3.client("s3")

# Environment variables
TABLE_NAME = os.environ["TABLE_NAME"]
BUCKET_NAME = os.environ["BUCKET_NAME"]

table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    print("Received event:", json.dumps(event))

    # Detect SQS
    if "Records" in event and "body" in event["Records"][0]:
        return handle_sqs(event)

    # Detect S3
    if "Records" in event and "s3" in event["Records"][0]:
        return handle_s3(event)

    return {"statusCode": 400, "body": "Unknown event"}


# ---------------------------
# SQS HANDLER
# ---------------------------
def handle_sqs(event):
    for record in event["Records"]:
        message = record["body"]
        print("Processing SQS message:", message)

        task_id = str(uuid.uuid4())

        # Store in DynamoDB
        table.put_item(
            Item={
                "task_id": task_id,
                "message": message,
                "status": "processed"
            }
        )

        print(f"Stored task {task_id} in DynamoDB")

    return {"statusCode": 200, "body": "SQS processed"}


# ---------------------------
# S3 HANDLER
# ---------------------------
def handle_s3(event):
    for record in event["Records"]:
        bucket = record["s3"]["bucket"]["name"]
        key = record["s3"]["object"]["key"]

        print(f"Processing file: {key}")

        # Example: store file metadata in DynamoDB
        table.put_item(
            Item={
                "task_id": str(uuid.uuid4()),
                "file_name": key,
                "bucket": bucket,
                "status": "uploaded"
            }
        )

    return {"statusCode": 200, "body": "S3 processed"}