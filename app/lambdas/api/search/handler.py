import os
import boto3
import json
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["TRACKS_TABLE"]
table = dynamodb.Table(TABLE_NAME)


def decimal_to_native(obj):
    if isinstance(obj, list):
        return [decimal_to_native(i) for i in obj]
    if isinstance(obj, dict):
        return {k: decimal_to_native(v) for k, v in obj.items()}
    if isinstance(obj, Decimal):
        return int(obj)
    return obj


def main(event, context):

    query = event.get("queryStringParameters", {}).get("q", "")

    if not query:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing query parameter"})
        }

    response = table.scan()

    items = response.get("Items", [])

    # simple contains search
    results = [
        {
            "trackId": item["PK"].replace("TRACK#", ""),
            "plays": decimal_to_native(item.get("plays", 0))
        }
        for item in items
        if query.lower() in item["PK"].lower()
    ]

    return {
        "statusCode": 200,
        "body": json.dumps(results)
    }
