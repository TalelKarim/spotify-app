import os
import boto3
from datetime import datetime

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["LISTENING_EVENTS_TABLE"]
table = dynamodb.Table(TABLE_NAME)

def main(event, context):

    detail = event.get("detail", event)
    timestamp = detail["timestamp"]

    date_key = timestamp[:10]  # YYYY-MM-DD

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

    return {"status": "analytics_updated"}
