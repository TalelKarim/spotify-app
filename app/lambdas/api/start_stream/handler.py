import json
import os
import boto3
from datetime import datetime

eventbridge = boto3.client("events")

EVENT_BUS_NAME = os.environ.get("EVENT_BUS_NAME", "default")

def handler(event, context):
    # 1️⃣ Récupération des infos d’entrée
    track_id = event["pathParameters"]["trackId"]

    headers = event.get("headers") or {}
    user_id = headers.get("X-User-Id", "anonymous")
    device = headers.get("X-Device", "unknown")
    country = headers.get("X-Country", "unknown")

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
