import json
import os
import boto3
from datetime import datetime

dynamodb = boto3.resource("dynamodb")
eventbridge = boto3.client("events")

EVENT_BUS_NAME = os.environ.get("EVENT_BUS_NAME", "default")
TRACKS_TABLE = os.environ["TRACKS_TABLE"]

tracks_table = dynamodb.Table(TRACKS_TABLE)


def main(event, context):

    track_id = event["pathParameters"]["trackId"]

    # 1️⃣ Vérifier existence du track
    response = tracks_table.get_item(
        Key={
            "PK": f"TRACK#{track_id}",
            "SK": "METADATA"
        }
    )

    item = response.get("Item")

    if not item:
        return {
            "statusCode": 404,
            "body": json.dumps({"error": "Track does not exist"})
        }

    # 🔥 NOUVEAU : Vérifier status READY
    if item.get("status") != "READY":
        return {
            "statusCode": 409,
            "body": json.dumps({"error": "Track not ready"})
        }

    # 2️⃣ Récupération user + headers
    headers = {k.lower(): v for k, v in (event.get("headers") or {}).items()}

    user_id = event["requestContext"]["authorizer"]["claims"]["sub"]
    device = headers.get("x-device")
    country = headers.get("x-country")

    if not user_id:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing authenticated user"})
        }

    # 3️⃣ Construction event métier
    listening_event = {
        "eventType": "TrackPlayed",
        "trackId": track_id,
        "userId": user_id,
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "source": "api",
        "metadata": {
            "device": device,
            "country": country
        }
    }

    # 4️⃣ Publish EventBridge
    eb_response = eventbridge.put_events(
        Entries=[
            {
                "Source": "spotify.api",
                "DetailType": "TrackPlayed",
                "Detail": json.dumps(listening_event),
                "EventBusName": EVENT_BUS_NAME
            }
        ]
    )

    if eb_response.get("FailedEntryCount", 0) > 0:
        print("❌ Failed to publish event:", eb_response)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Failed to publish event"})
        }

    return {
        "statusCode": 202,
        "body": json.dumps({
            "message": "Track play registered",
            "trackId": track_id
        })
    }