import json

def handler(event, context):
    for record in event['Records']:
        payload = json.loads(record['body'])
        
        user_id = payload.get('user_id')
        points = payload.get('points', 50)
        transaction_id = payload.get('transaction_id')
        
        print(f"SUCCESS: Processed reward for {user_id}. Awarded {points} points.")
        print(f"Transaction Reference: {transaction_id}")
        
    return {"statusCode": 200, "body": "Fulfillment complete"}