import base64
import json
import os
import boto3
from botocore.exceptions import ClientError

# Initialize the DynamoDB resource outside the handler for connection pooling
dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('TABLE_NAME')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    print(f"Processing {len(event['Records'])} records from Kinesis.")
    
    for record in event['Records']:
        try:
            # 1. Decode the Kinesis data
            payload = base64.b64decode(record['kinesis']['data']).decode('utf-8')
            data = json.loads(payload)
            
            # 2. Add some metadata (optional but recommended)
            data['kinesis_seq'] = record['kinesis']['sequenceNumber']
            data['processed_at'] = record['approximateArrivalTimestamp']
            
            # 3. Write to DynamoDB
            # This assumes your 'data' dictionary contains the Primary Key for your table
            table.put_item(Item=data)
            
        except Exception as e:
            print(f"Error processing record: {e}")
            # In production, you might want to raise this to trigger a retry 
            # or send to a Dead Letter Queue (DLQ).
            raise e

    return {
        'statusCode': 200,
        'body': json.dumps('Successfully processed batch.')
    }