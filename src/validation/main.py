import json
import os
import boto3
import uuid
from datetime import datetime

#Initialize AWS client

dynamodb = boto3.resource('dynamodb')
sqs = boto3.client('sqs')

def handler(event, context):
    try:
        #1 parse incomming events
        body = json.loads(event.get('body', '{}'))
        user_id = body.get('user_id')
        survey_id = body.get('survey_id')

        if not user_id or not survey_id:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'Missing user_id or survey_id'})
            }
        
        #2 Assign points based on logic
        points_awarded = 50
        transaction_id = str(uuid.uuid4())
        timestamp = datetime.utcnow().isoformat()
        
        #3 Write to Db
        table_name = os.environ['DYNAMODB_TABLE_NAME']
        table = dynamodb.Table(table_name)

        table.put_item(
            Item={
                'PK': f"USER#{user_id}",
                'SK': f"SURVEY#{survey_id}",
                "TransactionID": transaction_id,
                'Points': points_awarded,
                "Timestamp": timestamp
            }
        )

        #4 Trigger fullfillment by sending message to SQS
        queue_url = os.environ['SQS_QUEUE_URL']
        message_body = {
            "user_id": user_id,
            "transaction_id": transaction_id,
            "points_awarded": points_awarded
        }

        sqs.send_message(
            QueueUrl = queue_url,
            MessageBody = json.dumps(message_body)
        )

        #5 Return fast response to API gateway
        return {
                "statusCode": 200,
                "headers": {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "Content-Type",
                    "Access-Control-Allow-Methods": "OPTIONS,POST"
                },
                "body": json.dumps({
                    "message": "Survey Processed Successfully",
                    "points": points_awarded,
                    "transaction_id": transaction_id
                })
            }
    
    except Exception as e:
        print(f"Error processing survey: {str(e)}")
        return{
            "statusCode": 500,
            "body": json.dumps({
                "error": "Internal Server Error"
            })
        }