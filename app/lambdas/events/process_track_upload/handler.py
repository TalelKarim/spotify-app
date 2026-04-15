import os
import boto3
import urllib.parse
import hashlib
from datetime import datetime
from io import BytesIO
from logger import StructuredLogger

from mutagen.mp3 import MP3
from mutagen import MutagenError

dynamodb = boto3.resource("dynamodb")
s3 = boto3.client("s3")

TABLE_NAME = os.environ["TRACKS_TABLE"]
table = dynamodb.Table(TABLE_NAME)
logger = StructuredLogger(__name__)


def read_s3_object_bytes(bucket, key):
    response = s3.get_object(Bucket=bucket, Key=key)
    return response["Body"].read()


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def extract_mp3_duration_seconds(data: bytes) -> int:
    audio = MP3(BytesIO(data))
    if not audio.info or audio.info.length is None:
        raise ValueError("Unable to extract MP3 duration")
    return max(1, int(round(audio.info.length)))


def mark_track_ready(track_pk, track_sk, actual_hash, duration_seconds):
    table.update_item(
        Key={"PK": track_pk, "SK": track_sk},
        UpdateExpression="""
            SET #status = :ready,
                actualAudioHash = :actual_hash,
                #duration = :duration,
                validatedAt = :validated_at
            REMOVE uploadExpiresAt, validationError
        """,
        ExpressionAttributeNames={
            "#status": "status",
            "#duration": "duration"
        },
        ExpressionAttributeValues={
            ":ready": "READY",
            ":actual_hash": actual_hash,
            ":duration": duration_seconds,
            ":validated_at": datetime.utcnow().isoformat() + "Z"
        }
    )



def mark_track_invalid(track_pk, track_sk, actual_hash, validation_error):
    update_expression = """
        SET #status = :invalid,
            validationError = :validation_error,
            validatedAt = :validated_at
        REMOVE uploadExpiresAt
    """

    expression_values = {
        ":invalid": "INVALID",
        ":validation_error": validation_error,
        ":validated_at": datetime.utcnow().isoformat() + "Z"
    }

    if actual_hash:
        update_expression = """
            SET #status = :invalid,
                actualAudioHash = :actual_hash,
                validationError = :validation_error,
                validatedAt = :validated_at
            REMOVE uploadExpiresAt
        """
        expression_values[":actual_hash"] = actual_hash

    table.update_item(
        Key={"PK": track_pk, "SK": track_sk},
        UpdateExpression=update_expression,
        ExpressionAttributeNames={
            "#status": "status"
        },
        ExpressionAttributeValues=expression_values
    )


def mark_lock_ready(audio_hash):
    table.update_item(
        Key={"PK": f"AUDIOHASH#{audio_hash}", "SK": "LOCK"},
        UpdateExpression="""
            SET #status = :ready,
                validatedAt = :validated_at
            REMOVE expiresAt, validationError
        """,
        ExpressionAttributeNames={
            "#status": "status"
        },
        ExpressionAttributeValues={
            ":ready": "READY",
            ":validated_at": datetime.utcnow().isoformat() + "Z"
        }
    )


def mark_lock_invalid(audio_hash, validation_error):
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
            ":validation_error": validation_error,
            ":validated_at": datetime.utcnow().isoformat() + "Z"
        }
    )

def mark_track_ready_legacy(track_pk, track_sk, actual_hash, duration_seconds):
    table.update_item(
        Key={"PK": track_pk, "SK": track_sk},
        UpdateExpression="""
            SET #status = :ready,
                audioHash = :audio_hash,
                actualAudioHash = :actual_hash,
                #duration = :duration,
                validatedAt = :validated_at
            REMOVE uploadExpiresAt, validationError
        """,
        ExpressionAttributeNames={
            "#status": "status",
            "#duration": "duration"
        },
        ExpressionAttributeValues={
            ":ready": "READY",
            ":audio_hash": actual_hash,
            ":actual_hash": actual_hash,
            ":duration": duration_seconds,
            ":validated_at": datetime.utcnow().isoformat() + "Z"
        }
    )



def process_record(record):
    bucket = record["s3"]["bucket"]["name"]
    key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])

    logger.set_context(trackKey=key)

    if not key.startswith("tracks/") or not key.endswith(".mp3"):
        logger.info("Ignoring non-track upload event")
        return {"key": key, "status": "ignored"}

    track_id = key.split("/")[-1].replace(".mp3", "")

    pk = f"TRACK#{track_id}"
    sk = "METADATA"

    response = table.get_item(Key={"PK": pk, "SK": sk})
    item = response.get("Item")

    if not item:
        logger.warning("Track metadata not found for upload")
        return {"key": key, "status": "track_not_found"}

    expected_hash = item.get("audioHash")

    try:
        audio_bytes = read_s3_object_bytes(bucket, key)
        actual_hash = sha256_bytes(audio_bytes)
    except Exception:
        logger.exception("Failed to read uploaded audio")
        # on laisse l’event échouer pour retry automatique
        raise

    try:
        duration_seconds = extract_mp3_duration_seconds(audio_bytes)
    except (MutagenError, ValueError):
        mark_track_invalid(pk, sk, actual_hash, "AUDIO_DURATION_EXTRACT_FAILED")
        if expected_hash:
            mark_lock_invalid(expected_hash, "AUDIO_DURATION_EXTRACT_FAILED")
        logger.warning("Audio duration extraction failed", trackId=track_id)
        return {"key": key, "status": "invalid_duration_extract_failed"}

    # Compatibilité anciens tracks
    if not expected_hash:
        mark_track_ready_legacy(pk, sk, actual_hash, duration_seconds)
        logger.info("Track validated in legacy mode", trackId=track_id, duration=duration_seconds)
        return {"key": key, "status": "ready_legacy"}

    if actual_hash == expected_hash:
        mark_track_ready(pk, sk, actual_hash, duration_seconds)
        mark_lock_ready(expected_hash)
        logger.info("Track validated successfully", trackId=track_id, duration=duration_seconds)
        return {"key": key, "status": "ready"}

    mark_track_invalid(pk, sk, actual_hash, "AUDIO_HASH_MISMATCH")
    mark_lock_invalid(expected_hash, "AUDIO_HASH_MISMATCH")
    logger.warning("Audio hash mismatch detected", trackId=track_id)
    return {"key": key, "status": "invalid_hash_mismatch"}


def main(event, context):
    logger.clear_context()
    logger.set_lambda_context(context)
    logger.info("Processing uploaded track batch", recordCount=len(event.get("Records", [])))

    results = []

    for record in event.get("Records", []):
        results.append(process_record(record))

    return {
        "status": "processed",
        "results": results
    }
