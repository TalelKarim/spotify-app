import os
import boto3
import json
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")

TABLE_NAME = os.environ["TRACKS_TABLE"]
CLOUDFRONT_DOMAIN = os.environ.get("CLOUDFRONT_DOMAIN", "")

table = dynamodb.Table(TABLE_NAME)


# 🔹 Conversion DynamoDB Decimal → int / float
def decimal_to_native(obj):
    if isinstance(obj, Decimal):
        # Si c'est un entier
        if obj % 1 == 0:
            return int(obj)
        return float(obj)

    if isinstance(obj, list):
        return [decimal_to_native(x) for x in obj]

    if isinstance(obj, dict):
        return {k: decimal_to_native(v) for k, v in obj.items()}

    return obj


def main(event, context):

    path_params = event.get("pathParameters") or {}
    track_id = path_params.get("trackId")

    if not track_id:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing trackId"}),
            "headers": {"Content-Type": "application/json"}
        }

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
            "body": json.dumps({"error": "Track not found"}),
            "headers": {"Content-Type": "application/json"}
        }

    # 🔹 Convert Decimal → native types
    item = decimal_to_native(item)

    # 🔹 Bloquer si upload pas terminé
    if item.get("status") != "READY":
        return {
            "statusCode": 409,
            "body": json.dumps({"error": "Track not ready yet"}),
            "headers": {"Content-Type": "application/json"}
        }

    object_key = item.get("objectKey")
    cover_url = None
    
    if not object_key:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Missing object key"}),
            "headers": {"Content-Type": "application/json"}
        }

    audio_url = f"https://{CLOUDFRONT_DOMAIN}/{object_key}"
    cover_url = f"https://{CLOUDFRONT_DOMAIN}/{cover_key}"   
    return {
        "statusCode": 200,
        "body": json.dumps({
            "trackId": track_id,
            "title": item.get("title"),
            "artist": item.get("artist"),
            "duration": item.get("duration"),
            "plays": item.get("plays", 0),
            "audioUrl": audio_url
            "coverUrl": cover_url
        }),
        "headers": {
            "Content-Type": "application/json"
        }
    }