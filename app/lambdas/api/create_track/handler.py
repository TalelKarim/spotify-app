import json
import os
import boto3
from datetime import datetime
from botocore.exceptions import ClientError

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["TRACKS_TABLE"]
table = dynamodb.Table(TABLE_NAME)


def main(event, context):
    # Parsing du body
    try:
        body = json.loads(event.get("body") or "{}")
    except json.JSONDecodeError:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Invalid JSON body"}),
            "headers": {"Content-Type": "application/json"}
        }

    track_id = body.get("trackId")
    title = body.get("title")
    artist = body.get("artist")
    audio_s3_key = body.get("audioS3Key")

    # Validation minimale
    if not track_id or not title:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "trackId and title are required"}),
            "headers": {"Content-Type": "application/json"}
        }

    # Si tu considères que le path audio est obligatoire (recommandé) :
    if not audio_s3_key:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "audioS3Key is required"}),
            "headers": {"Content-Type": "application/json"}
        }

    pk = f"TRACK#{track_id}"
    sk = "METADATA"

    try:
        table.put_item(
            Item={
                "PK": pk,
                "SK": sk,
                "trackId": track_id,
                "title": title,
                "artist": artist,
                "plays": 0,
                "audioS3Key": audio_s3_key,
                "createdAt": datetime.utcnow().isoformat() + "Z"
            },
            ConditionExpression="attribute_not_exists(PK)"
        )

    except ClientError as e:
        if e.response["Error"]["Code"] == "ConditionalCheckFailedException":
            # Le track existe déjà
            return {
                "statusCode": 409,
                "body": json.dumps({"error": "Track already exists"}),
                "headers": {"Content-Type": "application/json"}
            }
        # Autre erreur Dynamo → on laisse remonter pour qu'elle soit loggée
        raise

    return {
        "statusCode": 201,
        "body": json.dumps({
            "trackId": track_id,
            "message": "Track created"
        }),
        "headers": {"Content-Type": "application/json"}
    }
