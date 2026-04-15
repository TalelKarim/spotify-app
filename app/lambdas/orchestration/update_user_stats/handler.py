import os
import boto3
from botocore.exceptions import ClientError
from logger import StructuredLogger

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["USERS_TABLE"]
table = dynamodb.Table(TABLE_NAME)

logger = StructuredLogger(__name__)

def main(event, context):
    try:
        logger.clear_context()
        logger.set_lambda_context(context)

        detail = event.get("detail", event)

        correlation_id = detail.get("correlationId")
        user_id = detail["userId"]
        track_id = detail["trackId"]

        logger.set_context(correlation_id=correlation_id, user_id=user_id, track_id=track_id)
        logger.info("Updating user stats", user_id=user_id, track_id=track_id)

        pk = f"USER#{user_id}"
        sk = "METADATA"

        table.update_item(
            Key={
                "PK": pk,
                "SK": sk
            },
            UpdateExpression="""
                ADD totalPlays :inc
                SET lastPlayedTrack = :track
            """,
            ExpressionAttributeValues={
                ":inc": 1,
                ":track": track_id
            }
        )

        logger.info("User stats updated successfully")
        
        return {"status": "user_stats_updated", "correlationId": correlation_id}

    except ClientError as e:
        logger.error("DynamoDB error updating user stats", error=str(e))
        raise
    except Exception as e:
        logger.error("Failed to update user stats", error=str(e))
        raise