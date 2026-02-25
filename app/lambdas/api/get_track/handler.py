import os
import boto3
import json

dynamodb = boto3.resource("dynamodb")

TABLE_NAME = os.environ["TRACKS_TABLE"]
CLOUDFRONT_DOMAIN = os.environ["CLOUDFRONT_DOMAIN"]

table = dynamodb.Table(TABLE_NAME)


def main(event, context):

    track_id = event["pathParameters"]["trackId"]

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
        return {
            "statusCode": 404,
            "body": json.dumps({"error": "Track not found"})
        }

    # Bloquer si upload pas terminé
    if item.get("status") != "READY":
        return {
            "statusCode": 409,
            "body": json.dumps({"error": "Track not ready yet"})
        }

    object_key = item.get("objectKey")

    audio_url = f"https://{CLOUDFRONT_DOMAIN}/{object_key}"

    return {
        "statusCode": 200,
        "body": json.dumps({
            "trackId": track_id,
            "title": item.get("title"),
            "artist": item.get("artist"),
            "duration": item.get("duration"),
            "plays": item.get("plays", 0),
            "audioUrl": audio_url
        })
    }