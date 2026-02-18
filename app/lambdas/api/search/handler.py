import os
import json
import logging

import boto3
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


def main(event, context):
    # Récupérer le terme de recherche ?q=...
    params = event.get("queryStringParameters") or {}
    query = params.get("q") or ""
    if not query:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing query parameter 'q'"}),
        }

    # Simple multi_match sur title + artist
    body = {
        "query": {
            "multi_match": {
                "query": query,
                "fields": ["title^2", "artist"],
            }
        },
        "size": 20,
    }

    url = f"{OPENSEARCH_ENDPOINT}/{INDEX_NAME}/_search"
    try:
        r = requests.post(
            url,
            auth=awsauth,
            json=body,
            headers={"Content-Type": "application/json"},
            timeout=3,
        )
    except Exception as e:
        logger.exception("Error calling OpenSearch: %s", e)
        return {
            "statusCode": 502,
            "body": json.dumps({"error": "Search backend unavailable"}),
        }

    if r.status_code >= 300:
        logger.error("OpenSearch error %s: %s", r.status_code, r.text)
        return {
            "statusCode": 502,
            "body": json.dumps({"error": "Search query failed"}),
        }

    data = r.json()
    hits = data.get("hits", {}).get("hits", [])

    results = [
        {
            "trackId": h["_source"].get("trackId"),
            "title": h["_source"].get("title"),
            "artist": h["_source"].get("artist"),
            "audioS3Key": h["_source"].get("audioS3Key"),
            "score": h.get("_score"),
        }
        for h in hits
    ]

    return {
        "statusCode": 200,
        "body": json.dumps({"results": results}),
        "headers": {"Content-Type": "application/json"},
    }
