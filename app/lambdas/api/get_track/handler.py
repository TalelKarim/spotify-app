import os
import boto3
import json
from decimal import Decimal
from logger import StructuredLogger

dynamodb = boto3.resource("dynamodb")

TABLE_NAME = os.environ["TRACKS_TABLE"]
CLOUDFRONT_DOMAIN = os.environ.get("CLOUDFRONT_DOMAIN", "").strip()
ALLOWED_ORIGIN = os.environ.get("ALLOWED_ORIGIN", "http://localhost:5173")

table = dynamodb.Table(TABLE_NAME)
logger = StructuredLogger(__name__)


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


def build_response(status_code, body):
    return {
        "statusCode": status_code,
        "body": json.dumps(body),
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": ALLOWED_ORIGIN,
            "Access-Control-Allow-Credentials": "true",
        }
    }


def build_cloudfront_url(key):
    if not key or not CLOUDFRONT_DOMAIN:
        return None
    return f"https://{CLOUDFRONT_DOMAIN}/{key}"


def main(event, context):
    logger.clear_context()
    logger.set_lambda_context(context)

    path_params = event.get("pathParameters") or {}
    track_id = path_params.get("trackId")
    logger.set_context(trackId=track_id)

    if not track_id:
        logger.error("Missing track identifier")
        return build_response(400, {"error": "Missing trackId"})

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
        logger.warning("Track not found")
        return build_response(404, {"error": "Track not found"})

    item = decimal_to_native(item)

    # Route publique => on ne retourne que les tracks READY
    if item.get("status") != "READY":
        logger.warning("Track is not publicly available", status=item.get("status"))
        return build_response(404, {"error": "Track not found"})

    object_key = item.get("objectKey")
    cover_key = item.get("coverKey")

    if not object_key:
        logger.error("Track is missing object key")
        return build_response(500, {"error": "Missing object key"})

    if not CLOUDFRONT_DOMAIN:
        logger.error("CloudFront domain is not configured")
        return build_response(500, {"error": "Missing CloudFront domain configuration"})

    audio_url = build_cloudfront_url(object_key)
    cover_url = build_cloudfront_url(cover_key)

    logger.info("Fetched track details")

    return build_response(200, {
        "trackId": track_id,
        "title": item.get("title"),
        "artist": item.get("artist"),
        "duration": item.get("duration"),
        "plays": item.get("plays", 0),
        "audioUrl": audio_url,
        "coverUrl": cover_url
    })