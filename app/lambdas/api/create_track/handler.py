import json
import os
import uuid
import boto3
from botocore.config import Config
from datetime import datetime
import time

REGION = os.environ.get("AWS_REGION", "eu-west-1")
ALLOWED_ORIGIN = os.environ.get("ALLOWED_ORIGIN", "http://localhost:5173")

dynamodb = boto3.resource("dynamodb")

s3 = boto3.client(
    "s3",
    region_name=REGION,
    endpoint_url=f"https://s3.{REGION}.amazonaws.com",
    config=Config(
        signature_version="s3v4",
        s3={"addressing_style": "virtual"}
    )
)

TABLE_NAME = os.environ["TRACKS_TABLE"]
BUCKET_NAME = os.environ["TRACKS_BUCKET"]

table = dynamodb.Table(TABLE_NAME)


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


# -------- AUTH HELPERS --------

def extract_claims(event):
    rc = event.get("requestContext", {}) or {}
    auth = rc.get("authorizer", {}) or {}

    claims = auth.get("claims")

    if not claims:
        jwt = auth.get("jwt") or {}
        claims = jwt.get("claims")

    return claims or {}


def extract_groups(event):
    claims = extract_claims(event)

    groups = claims.get("cognito:groups")

    if not groups:
        return []

    if isinstance(groups, list):
        return groups

    return [g.strip() for g in str(groups).split(",") if g.strip()]


def require_admin(event):
    groups = extract_groups(event)

    if "admin" not in groups:
        return build_response(403, {"error": "Admin only"})

    return None


# -------- MAIN HANDLER --------

def main(event, context):
    # Admin check
    deny = require_admin(event)
    if deny:
        return deny

    try:
        body = json.loads(event["body"])
    except Exception:
        return build_response(400, {"error": "Invalid JSON"})

    # -------- VALIDATION --------

    title = body.get("title")
    artist = body.get("artist")
    duration = body.get("duration")

    if not title or not artist:
        return build_response(400, {"error": "Missing required fields"})

    # Cover content type
    cover_content_type = body.get("coverContentType", "image/jpeg")

    if not cover_content_type.startswith("image/"):
        return build_response(400, {"error": "Invalid cover type"})

    extension_map = {
        "image/jpeg": "jpg",
        "image/png": "png",
        "image/webp": "webp"
    }

    cover_ext = extension_map.get(cover_content_type)

    if not cover_ext:
        return build_response(400, {"error": "Unsupported cover format"})

    # -------- GENERATE IDS --------

    track_id = str(uuid.uuid4())

    audio_key = f"tracks/{track_id}.mp3"
    cover_key = f"covers/{track_id}.{cover_ext}"

    upload_expiration = int(time.time()) + (15 * 60)

    # -------- DYNAMODB --------

    table.put_item(
        Item={
            "PK": f"TRACK#{track_id}",
            "SK": "METADATA",
            "trackId": track_id,
            "title": title,
            "artist": artist,
            "duration": duration,
            "objectKey": audio_key,
            "coverKey": cover_key,
            "status": "UPLOADING",
            "plays": 0,
            "createdAt": datetime.utcnow().isoformat() + "Z",
            "uploadExpiresAt": upload_expiration
        }
    )

    # -------- PRESIGNED URL AUDIO --------

    audio_upload_url = s3.generate_presigned_url(
        ClientMethod="put_object",
        Params={
            "Bucket": BUCKET_NAME,
            "Key": audio_key,
            "ContentType": "audio/mpeg"
        },
        ExpiresIn=300
    )

    # -------- PRESIGNED URL COVER --------

    cover_upload_url = s3.generate_presigned_url(
        ClientMethod="put_object",
        Params={
            "Bucket": BUCKET_NAME,
            "Key": cover_key,
            "ContentType": cover_content_type
        },
        ExpiresIn=300
    )

    # -------- RESPONSE --------

    return build_response(201, {
        "trackId": track_id,
        "audioUploadUrl": audio_upload_url,
        "coverUploadUrl": cover_upload_url,
        "audioKey": audio_key,
        "coverKey": cover_key
    })