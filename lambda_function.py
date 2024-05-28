# lambda_function.py
import json
from mangum import Mangum
from app.main import app

handler = Mangum(app)

def lambda_handler(event, context):
    if event.get("requestContext"):
        response = handler(event, context)
        return response
    else:
        return {
            'statusCode': 200,
            'body': json.dumps('Hello from Lambda!')
        }
