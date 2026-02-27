import json
import os
import uuid
import boto3
from botocore.config import Config
from datetime import datetime

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

def main(event, context):

    try:
        body = json.loads(event["body"])
    except:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Invalid JSON"})
        }

    # Basic validation
    title = body.get("title")
    artist = body.get("artist")
    duration = body.get("duration")

    if not title or not artist:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing required fields"})
        }

    # Generate track ID
    track_id = str(uuid.uuid4())

    # Object key inside S3
    object_key = f"tracks/{track_id}.mp3"

    # Write metadata in DynamoDB
    table.put_item(
        Item={
            "PK": f"TRACK#{track_id}",
            "SK": "METADATA",
            "title": title,
            "artist": artist,
            "duration": duration,
            "objectKey": object_key,
            "status": "UPLOADING",
            "plays": 0,
            "createdAt": datetime.utcnow().isoformat() + "Z"
        }
    )

    # Generate presigned PUT URL
    upload_url = s3.generate_presigned_url(
        ClientMethod="put_object",
        Params={
            "Bucket": BUCKET_NAME,
            "Key": object_key,
            "ContentType": "audio/mpeg"
        },
        ExpiresIn=300  # 5 minutes
    )

    return {
        "statusCode": 201,
        "body": json.dumps({
            "trackId": track_id,
            "uploadUrl": upload_url
        })
    }