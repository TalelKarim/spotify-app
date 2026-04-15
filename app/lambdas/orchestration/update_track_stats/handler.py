import os
import boto3
from datetime import datetime
from logger import StructuredLogger

from botocore.exceptions import ClientError



dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["TRACKS_TABLE"]
table = dynamodb.Table(TABLE_NAME)
logger = StructuredLogger(__name__)

def main(event, context):
    logger.clear_context()
    logger.set_lambda_context(context)

    detail = event.get("detail", event)

    correlation_id = detail.get("correlationId")
    track_id = detail["trackId"]
    timestamp = detail["timestamp"]

    logger.set_context(correlationId=correlation_id, trackId=track_id)
    logger.info("Updating orchestrated track stats", timestamp=timestamp)

    pk = f"TRACK#{track_id}"
    sk = "METADATA"
    
    try: 

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
            },
            ConditionExpression="attribute_exists(PK)"

        )

    except ClientError as e:
        if e.response["Error"]["Code"] == "ConditionalCheckFailedException":
            logger.warning("Track does not exist during orchestrated stats update")
            raise Exception("Track does not exist")
        logger.error("DynamoDB error updating orchestrated track stats", error=str(e))
        raise   

    logger.info("Orchestrated track stats updated")
    return {"status": "track_stats_updated"}
