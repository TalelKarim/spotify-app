import json
import os
import boto3
from datetime import datetime



def handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Hello World !",
        })
    }
