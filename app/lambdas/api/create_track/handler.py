import json
import os
import uuid
import boto3
from botocore.config import Config
from datetime import datetime
import time

REGION = os.environ.get("AWS_REGION", "eu-west-1")

dynamodb = boto3.resource("dynamodb")

s3 = boto3.client(
    "s3",
    region_name=REGION,
    config=Config(signature_version="s3v4")
)

TABLE_NAME = os.environ["TRACKS_TABLE"]
BUCKET_NAME = os.environ["TRACKS_BUCKET"]

table = dynamodb.Table(TABLE_NAME)


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
        return {
            "statusCode": 403,
            "body": json.dumps({"error": "Admin only"}),
            "headers": {"Content-Type": "application/json"}
        }

    return None


# -------- MAIN HANDLER --------

def main(event, context):

    # Admin check
    deny = require_admin(event)
    if deny:
        return deny

    try:
        body = json.loads(event["body"])
    except:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Invalid JSON"})
        }

    # -------- VALIDATION --------

    title = body.get("title")
    artist = body.get("artist")
    duration = body.get("duration")

    if not title or not artist:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing required fields"})
        }

    # Cover content type
    cover_content_type = body.get("coverContentType", "image/jpeg")

    if not cover_content_type.startswith("image/"):
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Invalid cover type"})
        }

    extension_map = {
        "image/jpeg": "jpg",
        "image/png": "png",
        "image/webp": "webp"
    }

    cover_ext = extension_map.get(cover_content_type)

    if not cover_ext:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Unsupported cover format"})
        }

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

    return {
        "statusCode": 201,
        "body": json.dumps({
            "trackId": track_id,
            "audioUploadUrl": audio_upload_url,
            "coverUploadUrl": cover_upload_url,
            "audioKey": audio_key,
            "coverKey": cover_key
        }),
        "headers": {"Content-Type": "application/json"}
    }