import os
import boto3
import json
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["TRACKS_TABLE"]
ALLOWED_ORIGIN = os.environ.get("ALLOWED_ORIGIN", "http://localhost:5173")
table = dynamodb.Table(TABLE_NAME)


def decimal_to_native(obj):
    if isinstance(obj, Decimal):
        if obj % 1 == 0:
            return int(obj)
        else:
            return float(obj)
    return obj


def build_response(status_code, body):
    return {
        "statusCode": status_code,
        "body": json.dumps(body),
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": ALLOWED_ORIGIN,
            "Access-Control-Allow-Credentials": "true",
        },
    }


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
        return build_response(404, {"error": "Track not found"})

    stats = {
        "trackId": track_id,
        "plays": decimal_to_native(item.get("plays", 0)),
        "lastPlayedAt": item.get("lastPlayedAt"),
    }

    return build_response(200, stats)