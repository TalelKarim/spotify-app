import json
import os
import boto3
from datetime import datetime
from botocore.exceptions import ClientError

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["TRACKS_TABLE"]
table = dynamodb.Table(TABLE_NAME)


def main(event, context):

    try:
        body = json.loads(event.get("body") or "{}")
    except json.JSONDecodeError:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Invalid JSON body"})
        }

    track_id = body.get("trackId")
    title = body.get("title")
    artist = body.get("artist")

    if not track_id or not title:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "trackId and title are required"})
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
                "createdAt": datetime.utcnow().isoformat() + "Z"
            },
            ConditionExpression="attribute_not_exists(PK)"
        )

    except ClientError as e:
        if e.response["Error"]["Code"] == "ConditionalCheckFailedException":
            return {
                "statusCode": 409,
                "body": json.dumps({"error": "Track already exists"})
            }
        raise

    return {
        "statusCode": 201,
        "body": json.dumps({
            "trackId": track_id,
            "message": "Track created"
        })
    }
