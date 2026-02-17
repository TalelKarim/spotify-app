import os
import boto3
import json
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["TRACKS_TABLE"]
table = dynamodb.Table(TABLE_NAME)


def decimal_to_native(obj):
    if isinstance(obj, Decimal):
        if obj % 1 == 0:
            return int(obj)
        else:
            return float(obj)
    if isinstance(obj, list):
        return [decimal_to_native(x) for x in obj]
    if isinstance(obj, dict):
        return {k: decimal_to_native(v) for k, v in obj.items()}
    return obj


def main(event, context):
    # pathParameters.trackId vient d'API Gateway : /tracks/{trackId}
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
            "body": json.dumps({"error": "Track not found"}),
            "headers": {
                "Content-Type": "application/json"
            }
        }

    # On enlève PK/SK et on convertit les décimaux
    cleaned = {k: v for k, v in item.items() if k not in ("PK", "SK")}
    cleaned = decimal_to_native(cleaned)

    # On force trackId cohérent avec l'URL (au cas où)
    cleaned["trackId"] = track_id

    # Exemple de champ qui sera présent si tu l'as mis à la création :
    # cleaned["audioS3Key"]  -> "audio/tracks/track-123.mp3"

    return {
        "statusCode": 200,
        "body": json.dumps(cleaned),
        "headers": {
            "Content-Type": "application/json",
        },
    }
