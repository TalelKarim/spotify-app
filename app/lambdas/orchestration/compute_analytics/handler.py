import os
import boto3
from datetime import datetime
from logger import StructuredLogger

dynamodb = boto3.resource("dynamodb")

TABLE_NAME = os.environ["ANALYTICS_TABLE"]  # 🔥 CORRECTION
table = dynamodb.Table(TABLE_NAME)
logger = StructuredLogger(__name__)

def main(event, context):
    logger.clear_context()
    logger.set_lambda_context(context)

    detail = event.get("detail", event)
    correlation_id = detail.get("correlationId")
    timestamp = detail["timestamp"]

    logger.set_context(correlationId=correlation_id)

    date_key = timestamp[:10]
    logger.info("Updating global analytics", dateKey=date_key)

    pk = "ANALYTICS#GLOBAL"
    sk = f"DATE#{date_key}"

    table.update_item(
        Key={
            "PK": pk,
            "SK": sk
        },
        UpdateExpression="ADD dailyPlays :inc",
        ExpressionAttributeValues={
            ":inc": 1
        }
    )

    logger.info("Global analytics updated", dateKey=date_key)
    return {"status": "analytics_updated"}