import json

def handler(event, context):
    # API Gateway passes the URL parameter here:
    transaction_id = event['pathParameters']['transaction_id']
    
    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "OPTIONS,GET"
        },
        "body": json.dumps({
            "transaction_id": transaction_id,
            "status": "Complete",
            "message": "Reward processed successfully!"
        })
    }