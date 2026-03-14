import os
import boto3
import urllib.parse
import hashlib
from datetime import datetime

dynamodb = boto3.resource("dynamodb")
s3 = boto3.client("s3")

TABLE_NAME = os.environ["TRACKS_TABLE"]
table = dynamodb.Table(TABLE_NAME)


def sha256_s3_object(bucket, key):
    response = s3.get_object(Bucket=bucket, Key=key)
    body = response["Body"]

    hasher = hashlib.sha256()

    while True:
        chunk = body.read(1024 * 1024)  # 1 MB
        if not chunk:
            break
        hasher.update(chunk)

    return hasher.hexdigest()


def mark_track_ready(track_pk, track_sk, actual_hash):
    table.update_item(
        Key={"PK": track_pk, "SK": track_sk},
        UpdateExpression="""
            SET #status = :ready,
                actualAudioHash = :actual_hash,
                validatedAt = :validated_at
            REMOVE uploadExpiresAt
        """,
        ExpressionAttributeNames={
            "#status": "status"
        },
        ExpressionAttributeValues={
            ":ready": "READY",
            ":actual_hash": actual_hash,
            ":validated_at": datetime.utcnow().isoformat() + "Z"
        }
    )


def mark_track_invalid(track_pk, track_sk, actual_hash):
    table.update_item(
        Key={"PK": track_pk, "SK": track_sk},
        UpdateExpression="""
            SET #status = :invalid,
                actualAudioHash = :actual_hash,
                validationError = :validation_error,
                validatedAt = :validated_at
            REMOVE uploadExpiresAt
        """,
        ExpressionAttributeNames={
            "#status": "status"
        },
        ExpressionAttributeValues={
            ":invalid": "INVALID",
            ":actual_hash": actual_hash,
            ":validation_error": "AUDIO_HASH_MISMATCH",
            ":validated_at": datetime.utcnow().isoformat() + "Z"
        }
    )


def mark_lock_ready(audio_hash, track_id):
    table.update_item(
        Key={"PK": f"AUDIOHASH#{audio_hash}", "SK": "LOCK"},
        UpdateExpression="""
            SET #status = :ready,
                validatedAt = :validated_at
            REMOVE expiresAt
        """,
        ExpressionAttributeNames={
            "#status": "status"
        },
        ExpressionAttributeValues={
            ":ready": "READY",
            ":validated_at": datetime.utcnow().isoformat() + "Z"
        }
    )


def mark_lock_invalid(audio_hash, track_id):
    table.update_item(
        Key={"PK": f"AUDIOHASH#{audio_hash}", "SK": "LOCK"},
        UpdateExpression="""
            SET #status = :invalid,
                validationError = :validation_error,
                validatedAt = :validated_at
            REMOVE expiresAt
        """,
        ExpressionAttributeNames={
            "#status": "status"
        },
        ExpressionAttributeValues={
            ":invalid": "INVALID",
            ":validation_error": "AUDIO_HASH_MISMATCH",
            ":validated_at": datetime.utcnow().isoformat() + "Z"
        }
    )


def process_record(record):
    bucket = record["s3"]["bucket"]["name"]
    key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])

    # On ne traite ici que les MP3 de tracks
    if not key.startswith("tracks/") or not key.endswith(".mp3"):
        return {"key": key, "status": "ignored"}

    track_id = key.split("/")[-1].replace(".mp3", "")

    pk = f"TRACK#{track_id}"
    sk = "METADATA"

    response = table.get_item(Key={"PK": pk, "SK": sk})
    item = response.get("Item")

    if not item:
        return {"key": key, "status": "track_not_found"}

    expected_hash = item.get("audioHash")

    # Compatibilité avec les anciens tracks créés avant phase 2
    if not expected_hash:
        table.update_item(
            Key={"PK": pk, "SK": sk},
            UpdateExpression="""
                SET #status = :ready,
                    validatedAt = :validated_at
                REMOVE uploadExpiresAt
            """,
            ExpressionAttributeNames={
                "#status": "status"
            },
            ExpressionAttributeValues={
                ":ready": "READY",
                ":validated_at": datetime.utcnow().isoformat() + "Z"
            }
        )
        return {"key": key, "status": "ready_legacy"}

    actual_hash = sha256_s3_object(bucket, key)

    if actual_hash == expected_hash:
        mark_track_ready(pk, sk, actual_hash)
        mark_lock_ready(expected_hash, track_id)
        return {"key": key, "status": "ready"}

    mark_track_invalid(pk, sk, actual_hash)
    mark_lock_invalid(expected_hash, track_id)
    return {"key": key, "status": "invalid_hash_mismatch"}


def main(event, context):
    results = []

    for record in event.get("Records", []):
        results.append(process_record(record))

    return {
        "status": "processed",
        "results": results
    }
