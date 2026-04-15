import json
import os
import boto3
from datetime import datetime
from logger import StructuredLogger


logger = StructuredLogger(__name__)

def main(event, context):
    logger.clear_context()
    logger.set_lambda_context(context)
    logger.info("Received placeholder audio metadata ingestion request")

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Hello World !",
        })
    }


handler = main
