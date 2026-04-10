import json
import os
import boto3
from datetime import datetime
from logger import StructuredLogger

dynamodb = boto3.resource("dynamodb")

TABLE_NAME = os.environ["LISTENING_EVENTS_TABLE"]
table = dynamodb.Table(TABLE_NAME)

logger = StructuredLogger(__name__)

def main(event, context):
    """
    Event attendu = SQS → EventBridge
    Stocke les events d'écoute avec le correlation ID pour tracing
    """

    for record in event.get("Records", []):
        try:
            # 1️⃣ Body SQS = string JSON
            body = json.loads(record["body"])

            # 2️⃣ EventBridge enveloppe
            detail = body.get("detail", {})

            correlation_id = detail.get("correlationId")
            track_id = detail["trackId"]
            user_id = detail["userId"]
            timestamp = detail["timestamp"]

            logger.set_context(correlation_id=correlation_id, user_id=user_id, track_id=track_id)
            logger.info("Storing listening event", event_detail=detail)

            pk = f"TRACK#{track_id}"
            sk = f"TS#{timestamp}"

            item = {
                "PK": pk,
                "SK": sk,
                "userId": user_id,
                "correlationId": correlation_id,  # Stored for backward tracking
                "eventType": detail["eventType"],
                # Global secondary index
                "GSI1PK": f"USER#{user_id}",
                "GSI1SK": f"TS#{timestamp}",

                "source": detail["source"],
                "metadata": detail.get("metadata", {}),
                "createdAt": datetime.utcnow().isoformat() + "Z"
            }

            table.put_item(Item=item)
            logger.info("Listening event stored successfully")
            
        except Exception as e:
            logger.error("Failed to store listening event", error=str(e), record=str(record))
            raise

    return {
        "status": "OK",
        "processed": len(event.get("Records", []))
    }
