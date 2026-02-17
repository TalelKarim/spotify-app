import os
import json
import base64
from decimal import Decimal

import boto3

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["TRACKS_TABLE"]
table = dynamodb.Table(TABLE_NAME)


def decimal_to_native(obj):
    if isinstance(obj, Decimal):
        if obj % 1 == 0:
            return int(obj)
        return float(obj)
    if isinstance(obj, list):
        return [decimal_to_native(x) for x in obj]
    if isinstance(obj, dict):
        return {k: decimal_to_native(v) for k, v in obj.items()}
    return obj


def decode_cursor(cursor_str):
    if not cursor_str:
        return None
    try:
        raw = base64.b64decode(cursor_str.encode("utf-8"))
        return json.loads(raw)
    except Exception:
        return None


def encode_cursor(key):
    if not key:
        return None
    raw = json.dumps(key).encode("utf-8")
    return base64.b64encode(raw).decode("utf-8")


def main(event, context):
    params = event.get("queryStringParameters") or {}

    limit = params.get("limit")
    try:
        limit = int(limit) if limit else 50
    except ValueError:
        limit = 50

    cursor = decode_cursor(params.get("cursor"))

    scan_kwargs = {
        "FilterExpression": "begins_with(#pk, :pk_prefix) AND #sk = :sk",
        "ExpressionAttributeNames": {
            "#pk": "PK",
            "#sk": "SK",
        },
        "ExpressionAttributeValues": {
            ":pk_prefix": "TRACK#",
            ":sk": "METADATA",
        },
        "Limit": limit,
    }

    if cursor:
        scan_kwargs["ExclusiveStartKey"] = cursor

    resp = table.scan(**scan_kwargs)

    items = []
    for item in resp.get("Items", []):
        # On enlève PK/SK et on convertit les décimaux
        cleaned = {k: v for k, v in item.items() if k not in ("PK", "SK")}
        cleaned = decimal_to_native(cleaned)

        # On extrait trackId depuis PK = "TRACK#xxx"
        pk = item["PK"]
        track_id = pk.split("#", 1)[1] if "#" in pk else pk
        cleaned["trackId"] = track_id

        items.append(cleaned)

    next_cursor = encode_cursor(resp.get("LastEvaluatedKey"))

    body = {
        "items": items,
        "nextCursor": next_cursor,
    }

    return {
        "statusCode": 200,
        "body": json.dumps(body),
        "headers": {
            "Content-Type": "application/json",
        },
    }
