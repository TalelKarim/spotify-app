import os
import json
import base64
from decimal import Decimal
from logger import StructuredLogger

import boto3
from boto3.dynamodb.conditions import Attr

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["TRACKS_TABLE"]
CLOUDFRONT_DOMAIN = os.environ.get("CLOUDFRONT_DOMAIN", "").strip()

table = dynamodb.Table(TABLE_NAME)
ALLOWED_ORIGIN = os.environ.get("ALLOWED_ORIGIN", "http://localhost:5173")
logger = StructuredLogger(__name__)





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


def build_cloudfront_url(key):
    if not key or not CLOUDFRONT_DOMAIN:
        return None
    return f"https://{CLOUDFRONT_DOMAIN}/{key}"


def sanitize_track(item):
    cleaned = {k: v for k, v in item.items() if k not in ("PK", "SK")}
    cleaned = decimal_to_native(cleaned)

    pk = item["PK"]
    track_id = pk.split("#", 1)[1] if "#" in pk else pk

    return {
        "trackId": track_id,
        "title": cleaned.get("title"),
        "artist": cleaned.get("artist"),
        "duration": cleaned.get("duration"),
        "plays": cleaned.get("plays", 0),
        "coverUrl": build_cloudfront_url(cleaned.get("coverKey")),
    }


def main(event, context):
    logger.clear_context()
    logger.set_lambda_context(context)

    params = event.get("queryStringParameters") or {}

    limit = params.get("limit")
    try:
        limit = int(limit) if limit else 50
    except ValueError:
        limit = 50

    if limit <= 0:
        limit = 50

    cursor = decode_cursor(params.get("cursor"))
    logger.info("Fetching public tracks", limit=limit, hasCursor=cursor is not None)

    items = []
    last_evaluated_key = cursor

    # On boucle car DynamoDB applique le Limit avant le FilterExpression
    while len(items) < limit:
        scan_kwargs = {
            "FilterExpression": (
                Attr("PK").begins_with("TRACK#")
                & Attr("SK").eq("METADATA")
                & Attr("status").eq("READY")
            ),
            "Limit": limit,
        }

        if last_evaluated_key:
            scan_kwargs["ExclusiveStartKey"] = last_evaluated_key

        resp = table.scan(**scan_kwargs)

        for item in resp.get("Items", []):
            items.append(sanitize_track(item))
            if len(items) >= limit:
                break

        last_evaluated_key = resp.get("LastEvaluatedKey")

        if not last_evaluated_key:
            break

    body = {
        "items": items,
        "nextCursor": encode_cursor(last_evaluated_key),
    }

    logger.info("Fetched public tracks", itemCount=len(items), hasNextCursor=body["nextCursor"] is not None)
    return build_response(200, {"items": items})