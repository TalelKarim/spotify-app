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
    # 1️⃣ Récupération des infos d’entrée
    track_id = event["pathParameters"]["trackId"]
    response = tracks_table.get_item(
            Key={
                "PK": f"TRACK#{track_id}",
                "SK": "METADATA"
            }
        )

    if "Item" not in response:
        return {
            "statusCode": 404,
            "body": json.dumps({"error": "Track does not exist"})
        }


    headers = {k.lower(): v for k, v in (event.get("headers") or {}).items()}

    user_id = headers.get("x-user-id")
    device = headers.get("x-device")
    country = headers.get("x-country")

    if not user_id:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing X-User-Id header"})
            }



    # 2️⃣ Construction de l’événement métier (CONTRAT)
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

    # 3️⃣ Publication dans EventBridge
    response = eventbridge.put_events(
        Entries=[
            {
                "Source": "spotify.api",
                "DetailType": "TrackPlayed",
                "Detail": json.dumps(listening_event),
                "EventBusName": EVENT_BUS_NAME
            }
        ]
    )

    # 4️⃣ Gestion d’erreur minimale mais propre
    if response.get("FailedEntryCount", 0) > 0:
        print("❌ Failed to publish event:", response)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Failed to publish event"})
        }

    # 5️⃣ Réponse immédiate au client
    return {
        "statusCode": 202,
        "body": json.dumps({
            "message": "Track play registered",
            "trackId": track_id
        })
    }
