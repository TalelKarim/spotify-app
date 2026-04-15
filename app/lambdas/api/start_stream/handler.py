import json
import os
import boto3
import uuid
from datetime import datetime
from logger import StructuredLogger

dynamodb = boto3.resource("dynamodb")
eventbridge = boto3.client("events")

EVENT_BUS_NAME = os.environ.get("EVENT_BUS_NAME", "default")
TRACKS_TABLE = os.environ["TRACKS_TABLE"]
ALLOWED_ORIGIN = os.environ.get("ALLOWED_ORIGIN", "http://localhost:5173")

tracks_table = dynamodb.Table(TRACKS_TABLE)
logger = StructuredLogger(__name__)


def build_response(status_code, body):
    return {
        "statusCode": status_code,
        "body": json.dumps(body),
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": ALLOWED_ORIGIN,
            "Access-Control-Allow-Credentials": "true",
        },
    }


def main(event, context):
    logger.clear_context()
    logger.set_lambda_context(context)

    # 0️⃣ Générer correlation ID unique pour tracer le flux
    correlation_id = str(uuid.uuid4())
    logger.set_correlation_id(correlation_id)
    
    track_id = event["pathParameters"]["trackId"]
    logger.info("Start stream request received", track=track_id)

    # 1️⃣ Vérifier existence du track
    response = tracks_table.get_item(
        Key={
            "PK": f"TRACK#{track_id}",
            "SK": "METADATA"
        }
    )

    item = response.get("Item")

    if not item:
        logger.error("Track not found", track=track_id)
        return build_response(404, {"error": "Track does not exist"})

    # 🔥 NOUVEAU : Vérifier status READY
    if item.get("status") != "READY":
        logger.warning("Track not ready", track=track_id, status=item.get("status"))
        return build_response(409, {"error": "Track not ready"})

    # 2️⃣ Récupération user + headers
    headers = {k.lower(): v for k, v in (event.get("headers") or {}).items()}

    user_id = event["requestContext"]["authorizer"]["claims"]["sub"]
    device = headers.get("x-device")
    country = headers.get("x-country")

    if not user_id:
        logger.error("Missing authenticated user")
        return build_response(400, {"error": "Missing authenticated user"})

    logger.set_context(user_id=user_id, track_id=track_id)

    # 3️⃣ Construction event métier avec correlation ID
    listening_event = {
        "correlationId": correlation_id,
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
    logger.info("Publishing TrackPlayed event to EventBridge", event_id=listening_event.get("correlationId"))
    
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
        logger.error("Failed to publish event to EventBridge", response=str(eb_response))
        return build_response(500, {"error": "Failed to publish event"})

    logger.info("Track play event published successfully")

    return build_response(202, {
        "message": "Track play registered",
        "trackId": track_id,
        "correlationId": correlation_id
    })