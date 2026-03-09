import os
import boto3
import json
from datetime import datetime
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["ANALYTICS_TABLE"]
table = dynamodb.Table(TABLE_NAME)

ALLOWED_ORIGIN = os.environ.get("ALLOWED_ORIGIN", "http://localhost:5173")


def decimal_to_native(obj):
    if isinstance(obj, list):
        return [decimal_to_native(i) for i in obj]
    if isinstance(obj, dict):
        return {k: decimal_to_native(v) for k, v in obj.items()}
    if isinstance(obj, Decimal):
        if obj % 1 == 0:
            return int(obj)
        return float(obj)
    return obj


def build_response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": ALLOWED_ORIGIN,
            "Access-Control-Allow-Credentials": "true",
        },
        "body": json.dumps(body),
    }


def main(event, context):
    today = datetime.utcnow().strftime("%Y-%m-%d")

    pk = "ANALYTICS#GLOBAL"
    sk = f"DATE#{today}"

    response = table.get_item(
        Key={
            "PK": pk,
            "SK": sk
        }
    )

    item = response.get("Item")

    if not item:
        return build_response(200, {
            "date": today,
            "dailyPlays": 0
        })

    item = decimal_to_native(item)

    return build_response(200, {
        "date": today,
        "dailyPlays": item.get("dailyPlays", 0)
    })