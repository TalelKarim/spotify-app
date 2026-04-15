import os
import json
from decimal import Decimal
from logger import StructuredLogger

import boto3
import requests
from requests_aws4auth import AWS4Auth
from boto3.dynamodb.types import TypeDeserializer
from requests import RequestException, Timeout


logger = StructuredLogger(__name__)

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
    logger.info("Indexing OpenSearch document", trackId=track_id, url=url)

    try:
        r = requests.put(
            url,
            auth=awsauth,
            json=doc,
            headers={"Content-Type": "application/json"},
            timeout=10,  # ← on passe à 10s
        )
        if not r.ok:
            logger.error("Failed to index OpenSearch document", trackId=track_id, statusCode=r.status_code, responseBody=r.text)
    except Timeout:
        logger.error("Timeout while indexing OpenSearch document", trackId=track_id, url=url)
    except RequestException as e:
        logger.error("Request exception while indexing OpenSearch document", trackId=track_id, error=str(e))


def _delete_document(track_id: str):
    """
    Supprime un document de l’index OpenSearch.
    """
    url = f"{OPENSEARCH_ENDPOINT}/{TRACKS_INDEX}/_doc/{track_id}"
    logger.info("Deleting OpenSearch document", trackId=track_id, url=url)

    try:
        r = requests.delete(
            url,
            auth=awsauth,
            headers={"Content-Type": "application/json"},
            timeout=10,  # ← pareil ici
        )
        # 404 = doc pas trouvé → pas grave
        if not r.ok and r.status_code != 404:
            logger.error("Failed to delete OpenSearch document", trackId=track_id, statusCode=r.status_code, responseBody=r.text)
    except Timeout:
        logger.error("Timeout while deleting OpenSearch document", trackId=track_id, url=url)
    except RequestException as e:
        logger.error("Request exception while deleting OpenSearch document", trackId=track_id, error=str(e))

def main(event, context):
    """
    Handler déclenché par DynamoDB Streams sur la table tracks.
    Gère INSERT / MODIFY / REMOVE.
    """
    logger.clear_context()
    logger.set_lambda_context(context)

    records = event.get("Records", [])
    logger.info("Received DynamoDB stream records", recordCount=len(records))

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
                logger.set_context(trackId=track_id)

                # Convertir l’image DynamoDB vers un dict natif
                deserializer = TypeDeserializer()
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
                logger.set_context(trackId=track_id)
                _delete_document(track_id)

        except Exception as e:
            logger.exception("Error processing DynamoDB stream record", error=str(e))

    return {"statusCode": 200, "body": json.dumps({"processed": len(records)})}
