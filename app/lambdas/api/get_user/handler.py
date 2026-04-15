import os
import boto3
import json
from decimal import Decimal
from logger import StructuredLogger

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["USERS_TABLE"]
table = dynamodb.Table(TABLE_NAME)
logger = StructuredLogger(__name__)


def decimal_to_int(value):
    if isinstance(value, Decimal):
        return int(value)
    return value


def main(event, context):
    logger.clear_context()
    logger.set_lambda_context(context)

    user_id = event["pathParameters"]["userId"]
    logger.set_context(userId=user_id)
    logger.info("Fetching user aggregate")

    pk = f"USER#{user_id}"
    sk = "METADATA"

    response = table.get_item(
        Key={
            "PK": pk,
            "SK": sk
        }
    )

    item = response.get("Item")

    if not item:
        logger.warning("User aggregate not found")
        return {
            "statusCode": 404,
            "body": json.dumps({"error": "User not found"})
        }

    logger.info("Fetched user aggregate", totalPlays=decimal_to_int(item.get("totalPlays", 0)))
    return {
        "statusCode": 200,
        "body": json.dumps({
            "userId": user_id,
            "totalPlays": decimal_to_int(item.get("totalPlays", 0)),
            "lastPlayedTrack": item.get("lastPlayedTrack")
        })
    }
