import json
import os
import boto3
from datetime import datetime

dynamodb = boto3.resource("dynamodb")

TABLE_NAME = os.environ["LISTENING_EVENTS_TABLE"]
table = dynamodb.Table(TABLE_NAME)

def main(event, context):
    """
    Event attendu = SQS → EventBridge
    """

    for record in event.get("Records", []):
        # 1️⃣ Body SQS = string JSON
        body = json.loads(record["body"])

        # 2️⃣ EventBridge enveloppe
        detail = body.get("detail", {})

        track_id = detail["trackId"]
        user_id = detail["userId"]
        timestamp = detail["timestamp"]

        pk = f"TRACK#{track_id}"
        sk = f"TS#{timestamp}"

        item = {
            "PK": pk,
            "SK": sk,
            "userId": user_id,
            "eventType": detail["eventType"],
            "source": detail["source"],
            "metadata": detail.get("metadata", {}),
            "createdAt": datetime.utcnow().isoformat() + "Z"
        }

        table.put_item(Item=item)

    return {
        "status": "OK",
        "processed": len(event.get("Records", []))
    }
