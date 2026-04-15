import json
import os
import re
import uuid
import boto3
from botocore.config import Config
from datetime import datetime
import time
from logger import StructuredLogger

REGION = os.environ.get("AWS_REGION", "eu-west-1")
ALLOWED_ORIGIN = os.environ.get("ALLOWED_ORIGIN", "http://localhost:5173")

dynamodb = boto3.resource("dynamodb")
ddb_client = boto3.client("dynamodb")

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

SHA256_RE = re.compile(r"^[a-f0-9]{64}$")
logger = StructuredLogger(__name__)


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


def normalize_text(value):
    return " ".join(str(value).strip().lower().split())


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
    logger.clear_context()
    logger.set_lambda_context(context)

    deny = require_admin(event)
    if deny:
        logger.warning("Non-admin attempted track creation")
        return deny

    try:
        body = json.loads(event["body"])
    except Exception:
        logger.warning("Invalid create track payload")
        return build_response(400, {"error": "Invalid JSON"})

    title = body.get("title")
    artist = body.get("artist")
    audio_hash = (body.get("audioHash") or "").strip().lower()

    if not title or not artist:
        logger.warning("Missing required track metadata")
        return build_response(400, {"error": "Missing required fields"})

    if not audio_hash:
        logger.warning("Missing audio hash")
        return build_response(400, {"error": "Missing audioHash"})

    if not SHA256_RE.match(audio_hash):
        logger.warning("Invalid audio hash format")
        return build_response(400, {"error": "Invalid audioHash format"})

    cover_content_type = body.get("coverContentType", "image/jpeg")

    if not cover_content_type.startswith("image/"):
        logger.warning("Invalid cover content type", coverContentType=cover_content_type)
        return build_response(400, {"error": "Invalid cover type"})

    extension_map = {
        "image/jpeg": "jpg",
        "image/png": "png",
        "image/webp": "webp"
    }

    cover_ext = extension_map.get(cover_content_type)

    if not cover_ext:
        logger.warning("Unsupported cover content type", coverContentType=cover_content_type)
        return build_response(400, {"error": "Unsupported cover format"})

    track_id = str(uuid.uuid4())
    logger.set_context(trackId=track_id)
    logger.info("Creating upload reservation for track")

    audio_key = f"tracks/{track_id}.mp3"
    cover_key = f"covers/{track_id}.{cover_ext}"

    now_ts = int(time.time())
    now_iso = datetime.utcnow().isoformat() + "Z"
    upload_expiration = now_ts + (15 * 60)

    lock_pk = f"AUDIOHASH#{audio_hash}"

    normalized_title = normalize_text(title)
    normalized_artist = normalize_text(artist)

    try:
        ddb_client.transact_write_items(
            TransactItems=[
                {
                    "Put": {
                        "TableName": TABLE_NAME,
                        "Item": {
                            "PK": {"S": lock_pk},
                            "SK": {"S": "LOCK"},
                            "entityType": {"S": "AUDIO_HASH_LOCK"},
                            "audioHash": {"S": audio_hash},
                            "trackId": {"S": track_id},
                            "status": {"S": "RESERVED"},
                            "createdAt": {"S": now_iso},
                            "expiresAt": {"N": str(upload_expiration)},
                        },
                        "ConditionExpression": "attribute_not_exists(PK) OR #status = :invalid OR #expiresAt < :now",
                        "ExpressionAttributeNames": {
                            "#status": "status",
                            "#expiresAt": "expiresAt",
                        },
                        "ExpressionAttributeValues": {
                            ":invalid": {"S": "INVALID"},
                            ":now": {"N": str(now_ts)},
                        },
                    }
                },
                {
                    "Put": {
                        "TableName": TABLE_NAME,
                        "Item": {
                            "PK": {"S": f"TRACK#{track_id}"},
                            "SK": {"S": "METADATA"},
                            "entityType": {"S": "TRACK"},
                            "trackId": {"S": track_id},
                            "title": {"S": title},
                            "artist": {"S": artist},
                            "normalizedTitle": {"S": normalized_title},
                            "normalizedArtist": {"S": normalized_artist},
                            # durée réelle calculée plus tard côté process_upload
                            "duration": {"N": "0"},
                            "objectKey": {"S": audio_key},
                            "coverKey": {"S": cover_key},
                            "audioHash": {"S": audio_hash},
                            "status": {"S": "UPLOADING"},
                            "plays": {"N": "0"},
                            "createdAt": {"S": now_iso},
                            "uploadExpiresAt": {"N": str(upload_expiration)},
                            "isCanonical": {"BOOL": True},
                            "duplicateOf": {"NULL": True},
                        }
                    }
                }
            ]
        )
    except ddb_client.exceptions.TransactionCanceledException:
        existing_track_id = None

        try:
            existing = ddb_client.get_item(
                TableName=TABLE_NAME,
                Key={
                    "PK": {"S": lock_pk},
                    "SK": {"S": "LOCK"}
                },
                ConsistentRead=True
            ).get("Item")

            if existing and "trackId" in existing:
                existing_track_id = existing["trackId"]["S"]
        except Exception:
            pass

        return build_response(409, {
            "error": "This audio file already exists on the platform",
            "existingTrackId": existing_track_id
        })

    audio_upload_url = s3.generate_presigned_url(
        ClientMethod="put_object",
        Params={
            "Bucket": BUCKET_NAME,
            "Key": audio_key,
            "ContentType": "audio/mpeg"
        },
        ExpiresIn=300
    )

    cover_upload_url = s3.generate_presigned_url(
        ClientMethod="put_object",
        Params={
            "Bucket": BUCKET_NAME,
            "Key": cover_key,
            "ContentType": cover_content_type
        },
        ExpiresIn=300
    )

    logger.info("Created upload reservation", audioKey=audio_key, coverKey=cover_key)

    return build_response(201, {
        "trackId": track_id,
        "audioUploadUrl": audio_upload_url,
        "coverUploadUrl": cover_upload_url,
        "audioKey": audio_key,
        "coverKey": cover_key
    })
