import os
import json
from decimal import Decimal
from logger import StructuredLogger

import boto3

dynamodb = boto3.resource("dynamodb")
ddb_client = boto3.client("dynamodb")

LISTENING_EVENTS_TABLE = os.environ["LISTENING_EVENTS_TABLE"]
TRACKS_TABLE = os.environ["TRACKS_TABLE"]
CLOUDFRONT_DOMAIN = os.environ.get("CLOUDFRONT_DOMAIN", "").strip()
ALLOWED_ORIGIN = os.environ.get("ALLOWED_ORIGIN", "http://localhost:5173")

listening_table = dynamodb.Table(LISTENING_EVENTS_TABLE)
logger = StructuredLogger(__name__)


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


def build_cloudfront_url(key):
    if not key or not CLOUDFRONT_DOMAIN:
        return None
    return f"https://{CLOUDFRONT_DOMAIN}/{key}"


def extract_user_id(event):
    rc = event.get("requestContext", {}) or {}
    auth = rc.get("authorizer", {}) or {}

    claims = auth.get("claims")
    if claims:
        return claims.get("sub") or claims.get("cognito:username")

    jwt = auth.get("jwt")
    if jwt and "claims" in jwt:
        c = jwt["claims"]
        return c.get("sub") or c.get("cognito:username")

    return None


def batch_get_tracks(track_ids):
    if not track_ids:
        return {}

    keys = [
        {
            "PK": {"S": f"TRACK#{track_id}"},
            "SK": {"S": "METADATA"},
        }
        for track_id in track_ids
    ]

    result = {}
    chunk_size = 100

    for i in range(0, len(keys), chunk_size):
        chunk = keys[i:i + chunk_size]

        request_items = {
            TRACKS_TABLE: {
                "Keys": chunk
            }
        }

        response = ddb_client.batch_get_item(RequestItems=request_items)
        items = response.get("Responses", {}).get(TRACKS_TABLE, [])

        for raw_item in items:
            item = {
                k: list(v.values())[0] if isinstance(v, dict) and len(v) == 1 else v
                for k, v in raw_item.items()
            }

            track_id = item.get("trackId")
            if not track_id:
                pk = item.get("PK", "")
                if pk.startswith("TRACK#"):
                    track_id = pk.replace("TRACK#", "", 1)

            if not track_id:
                continue

            result[track_id] = {
                "trackId": track_id,
                "title": item.get("title"),
                "artist": item.get("artist"),
                "coverUrl": build_cloudfront_url(item.get("coverKey")),
                "status": item.get("status"),
            }

    return result


def main(event, context):
    logger.clear_context()
    logger.set_lambda_context(context)

    user_id = extract_user_id(event)
    if not user_id:
        logger.warning("Unauthorized history request")
        return build_response(401, {"error": "Unauthorized"})

    logger.set_context(userId=user_id)

    params = event.get("queryStringParameters") or {}

    limit = params.get("limit")
    try:
        limit = int(limit) if limit else 50
    except ValueError:
        limit = 50

    limit = max(1, min(limit, 100))
    logger.info("Fetching listening history", limit=limit)

    pk = f"USER#{user_id}"

    resp = listening_table.query(
        IndexName="GSI1",
        KeyConditionExpression="GSI1PK = :pk",
        ExpressionAttributeValues={":pk": pk},
        ScanIndexForward=False,
        Limit=limit,
    )

    events = [decimal_to_native(item) for item in resp.get("Items", [])]

    track_ids = []
    for item in events:
        raw_pk = item.get("PK", "")
        if raw_pk.startswith("TRACK#"):
            track_ids.append(raw_pk.replace("TRACK#", "", 1))

    tracks_by_id = batch_get_tracks(list(dict.fromkeys(track_ids)))

    clean_items = []

    for item in events:
        raw_pk = item.get("PK", "")
        raw_sk = item.get("SK", "")

        track_id = raw_pk.replace("TRACK#", "", 1) if raw_pk.startswith("TRACK#") else raw_pk
        played_at = raw_sk.replace("TS#", "", 1) if raw_sk.startswith("TS#") else raw_sk

        track = tracks_by_id.get(track_id, {})

        clean_items.append({
            "trackId": track_id,
            "playedAt": played_at,
            "title": track.get("title"),
            "artist": track.get("artist"),
            "coverUrl": track.get("coverUrl"),
            "metadata": item.get("metadata", {})
        })

    body = {
        "userId": user_id,
        "items": clean_items,
    }

    logger.info("Fetched listening history", itemCount=len(clean_items))
    return build_response(200, body)