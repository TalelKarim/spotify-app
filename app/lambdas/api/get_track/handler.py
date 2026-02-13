import os
import boto3
import json

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["TRACKS_TABLE"]
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

    return {
        "statusCode": 200,
        "body": json.dumps({
            "trackId": track_id,
            "plays": item.get("plays", 0),
            "lastPlayedAt": item.get("lastPlayedAt")
        })
    }
