import os
import boto3
import json
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["TRACKS_TABLE"]
table = dynamodb.Table(TABLE_NAME)


def decimal_to_native(obj):
    if isinstance(obj, Decimal):
        if obj % 1 == 0:
            return int(obj)
        else:
            return float(obj)
    return obj


def main(event, context):

    track_id = event["pathParameters"]["trackId"]

    pk = f"TRACK#{track_id}"
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
            "body": json.dumps({"error": "Track not found"})
        }

    plays = decimal_to_native(item.get("plays", 0))

    return {
        "statusCode": 200,
        "body": json.dumps({
            "trackId": track_id,
            "plays": plays,
            "lastPlayedAt": item.get("lastPlayedAt")
        })
    }
