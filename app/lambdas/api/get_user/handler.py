import os
import boto3
import json
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["USERS_TABLE"]
table = dynamodb.Table(TABLE_NAME)


def decimal_to_int(value):
    if isinstance(value, Decimal):
        return int(value)
    return value


def main(event, context):

    user_id = event["pathParameters"]["userId"]

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
        return {
            "statusCode": 404,
            "body": json.dumps({"error": "User not found"})
        }

    return {
        "statusCode": 200,
        "body": json.dumps({
            "userId": user_id,
            "totalPlays": decimal_to_int(item.get("totalPlays", 0)),
            "lastPlayedTrack": item.get("lastPlayedTrack")
        })
    }
