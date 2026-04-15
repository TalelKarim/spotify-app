import os
import boto3
from datetime import datetime
from logger import StructuredLogger

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["TRACKS_TABLE"]
table = dynamodb.Table(TABLE_NAME)

logger = StructuredLogger(__name__)

def main(event, context):
    try:
        logger.clear_context()
        logger.set_lambda_context(context)

        detail = event.get("detail", event)

        correlation_id = detail.get("correlationId")
        track_id = detail["trackId"]
        user_id = detail["userId"]
        timestamp = detail["timestamp"]

        logger.set_context(correlation_id=correlation_id, user_id=user_id, track_id=track_id)
        logger.info("Updating track stats", track_id=track_id, timestamp=timestamp)

        pk = f"TRACK#{track_id}"
        sk = "METADATA"

        table.update_item(
            Key={
                "PK": pk,
                "SK": sk
            },
            UpdateExpression="""
                ADD plays :inc
                SET lastPlayedAt = :ts
            """,
            ExpressionAttributeValues={
                ":inc": 1,
                ":ts": timestamp
            }
        )

        logger.info("Track stats updated successfully")
        
        return {"status": "track_stats_updated", "correlationId": correlation_id}
        
    except Exception as e:
        logger.error("Failed to update track stats", error=str(e))
        raise
