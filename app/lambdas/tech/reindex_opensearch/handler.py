import os
import json
import logging
from decimal import Decimal

import boto3
import requests
from requests_aws4auth import AWS4Auth

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# --- Config OpenSearch depuis les variables d'env ---
RAW_ENDPOINT = os.environ["OPENSEARCH_ENDPOINT"]  # ex: vpc-spotify-dev-search-...eu-west-1.es.amazonaws.com
OPENSEARCH_REGION = os.environ.get("OPENSEARCH_REGION", "eu-west-1")
TRACKS_INDEX = os.environ.get("OPENSEARCH_INDEX_TRACKS", "tracks")

# On s’assure que l’endpoint a bien un schéma https://
if RAW_ENDPOINT.startswith("https://"):
    OPENSEARCH_ENDPOINT = RAW_ENDPOINT.rstrip("/")  # éviter double slash
else:
    OPENSEARCH_ENDPOINT = f"https://{RAW_ENDPOINT}".rstrip("/")

# --- Auth IAM SigV4 pour OpenSearch ---
session = boto3.Session()
credentials = session.get_credentials()
creds = credentials.get_frozen_credentials()

awsauth = AWS4Auth(
    creds.access_key,
    creds.secret_key,
    OPENSEARCH_REGION,
    "es",  # service OpenSearch/ES
    session_token=creds.token,
)


def _decimal_to_native(obj):
    if isinstance(obj, Decimal):
        if obj % 1 == 0:
            return int(obj)
        return float(obj)
    if isinstance(obj, list):
        return [_decimal_to_native(x) for x in obj]
    if isinstance(obj, dict):
        return {k: _decimal_to_native(v) for k, v in obj.items()}
    return obj


def _index_document(track_id: str, doc: dict):
    """
    Indexe ou met à jour un document dans OpenSearch.
    """
    url = f"{OPENSEARCH_ENDPOINT}/{TRACKS_INDEX}/_doc/{track_id}"
    logger.info(f"Indexing document track_id={track_id} url={url}")

    r = requests.put(
        url,
        auth=awsauth,
        json=doc,
        headers={"Content-Type": "application/json"},
        timeout=3,
    )
    if not r.ok:
        logger.error(
            f"Failed to index doc {track_id} - status={r.status_code} body={r.text}"
        )


def _delete_document(track_id: str):
    """
    Supprime un document de l’index OpenSearch.
    """
    url = f"{OPENSEARCH_ENDPOINT}/{TRACKS_INDEX}/_doc/{track_id}"
    logger.info(f"Deleting document track_id={track_id} url={url}")

    r = requests.delete(
        url,
        auth=awsauth,
        headers={"Content-Type": "application/json"},
        timeout=3,
    )
    if not r.ok and r.status_code != 404:
        logger.error(
            f"Failed to delete doc {track_id} - status={r.status_code} body={r.text}"
        )


def main(event, context):
    """
    Handler déclenché par DynamoDB Streams sur la table tracks.
    Gère INSERT / MODIFY / REMOVE.
    """
    records = event.get("Records", [])
    logger.info(f"Received {len(records)} records from stream")

    for record in records:
        try:
            event_name = record["eventName"]  # INSERT / MODIFY / REMOVE
            ddb = record["dynamodb"]

            if event_name in ("INSERT", "MODIFY"):
                new_image = ddb.get("NewImage", {})
                pk = new_image.get("PK", {}).get("S")
                sk = new_image.get("SK", {}).get("S")

                # On ne s’occupe que des METADATA de tracks
                if not pk or not pk.startswith("TRACK#") or sk != "METADATA":
                    continue

                track_id = pk.split("#", 1)[1]

                # Convertir l’image DynamoDB vers un dict natif
                deserializer = boto3.dynamodb.types.TypeDeserializer()
                native_item = {k: deserializer.deserialize(v) for k, v in new_image.items()}

                # Nettoyage : on retire PK/SK, on sanitise Decimal -> int/float
                native_item.pop("PK", None)
                native_item.pop("SK", None)
                native_item["trackId"] = track_id

                doc = _decimal_to_native(native_item)

                _index_document(track_id, doc)

            elif event_name == "REMOVE":
                old_image = ddb.get("OldImage", {})
                pk = old_image.get("PK", {}).get("S")
                sk = old_image.get("SK", {}).get("S")

                if not pk or not pk.startswith("TRACK#") or sk != "METADATA":
                    continue

                track_id = pk.split("#", 1)[1]
                _delete_document(track_id)

        except Exception as e:
            logger.exception(f"Error processing record: {e}")

    return {"statusCode": 200, "body": json.dumps({"processed": len(records)})}
