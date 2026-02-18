import os
import json
import logging

import boto3
from boto3.dynamodb.types import TypeDeserializer
import requests
from requests_aws4auth import AWS4Auth

logger = logging.getLogger()
logger.setLevel(logging.INFO)

region = os.environ.get("AWS_REGION", "eu-west-1")
service = "es"

session = boto3.Session()
credentials = session.get_credentials()
awsauth = AWS4Auth(
    credentials.access_key,
    credentials.secret_key,
    region,
    service,
    session_token=credentials.token,
)

OPENSEARCH_ENDPOINT = os.environ["OPENSEARCH_ENDPOINT"].rstrip("/")
INDEX_NAME = os.environ.get("OPENSEARCH_INDEX", "tracks")

deserializer = TypeDeserializer()


def _from_ddb(image: dict) -> dict:
    """Convertit un NewImage/OldImage DynamoDB en dict Python natif."""
    return {k: deserializer.deserialize(v) for k, v in image.items()}


def _index_document(doc_id: str, body: dict):
    url = f"{OPENSEARCH_ENDPOINT}/{INDEX_NAME}/_doc/{doc_id}"
    r = requests.put(
        url,
        auth=awsauth,
        json=body,
        headers={"Content-Type": "application/json"},
        timeout=3,
    )
    if r.status_code >= 300:
        logger.error("Failed to index doc %s: %s", doc_id, r.text)


def _delete_document(doc_id: str):
    url = f"{OPENSEARCH_ENDPOINT}/{INDEX_NAME}/_doc/{doc_id}"
    r = requests.delete(url, auth=awsauth, timeout=3)
    if r.status_code not in (200, 404):
        logger.error("Failed to delete doc %s: %s", doc_id, r.text)


def main(event, context):
    logger.info("Received %d records from stream", len(event.get("Records", [])))

    for record in event.get("Records", []):
        event_name = record["eventName"]
        ddb = record["dynamodb"]

        try:
            if event_name in ("INSERT", "MODIFY"):
                new_image = ddb.get("NewImage")
                if not new_image:
                    continue
                item = _from_ddb(new_image)

                # On ne traite que les lignes METADATA des tracks
                if item.get("SK") != "METADATA":
                    continue

                track_id = item.get("trackId")
                if not track_id:
                    continue

                doc = {
                    "trackId": track_id,
                    "title": item.get("title"),
                    "artist": item.get("artist"),
                    "audioS3Key": item.get("audioS3Key"),
                    "plays": item.get("plays", 0),
                    "createdAt": item.get("createdAt"),
                }

                _index_document(track_id, doc)

            elif event_name == "REMOVE":
                old_image = ddb.get("OldImage")
                if not old_image:
                    continue
                item = _from_ddb(old_image)

                if item.get("SK") != "METADATA":
                    continue

                track_id = item.get("trackId")
                if not track_id:
                    continue

                _delete_document(track_id)

        except Exception as e:  # on loggue mais on laisse Lambda gérer les retries
            logger.exception("Error processing record: %s", e)

    return {"statusCode": 200, "body": json.dumps({"message": "OK"})}
