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
creds = credentials.get_frozen_credentials()

awsauth = AWS4Auth(
    creds.access_key,
    creds.secret_key,
    region,
    service,
    session_token=creds.token,
)

RAW_ENDPOINT = os.environ["OPENSEARCH_ENDPOINT"].rstrip("/")
OPENSEARCH_ENDPOINT = RAW_ENDPOINT if RAW_ENDPOINT.startswith("http") else f"https://{RAW_ENDPOINT}"
INDEX_NAME = os.environ.get("OPENSEARCH_INDEX", "tracks")


def main(event, context):
    params = event.get("queryStringParameters") or {}

    q = (params.get("q") or "").strip()
    if not q:
        return {"statusCode": 400, "body": json.dumps({"error": "Missing query parameter 'q'"}), "headers": {"Content-Type": "application/json"}}

    # pagination
    try:
        size = int(params.get("limit") or 20)
    except ValueError:
        size = 20
    size = max(1, min(size, 50))

    try:
        offset = int(params.get("offset") or 0)
    except ValueError:
        offset = 0
    offset = max(0, offset)

    # sorting
    sort_mode = (params.get("sort") or "relevance").lower()
    if sort_mode == "popular":
        sort = [{"plays": "desc"}, {"_score": "desc"}]
    elif sort_mode == "new":
        sort = [{"createdAt": "desc"}, {"_score": "desc"}]
    else:
        sort = None  # relevance default

    # premium query
    body = {
        "from": offset,
        "size": size,
        "query": {
            "bool": {
                "filter": [
                    {"term": {"status.keyword": "READY"}}
                ],
                "should": [
                    # Exact-ish phrase match boosted
                    {"match_phrase": {"title": {"query": q, "boost": 4}}},
                    # Full text with fuzziness
                    {
                        "multi_match": {
                            "query": q,
                            "fields": ["title^2", "artist"],
                            "type": "best_fields",
                            "operator": "and",
                            "fuzziness": "AUTO"
                        }
                    }
                ],
                "minimum_should_match": 1
            }
        },
        "highlight": {
            "pre_tags": ["<em>"],
            "post_tags": ["</em>"],
            "fields": {
                "title": {},
                "artist": {}
            }
        }
    }

    if sort:
        body["sort"] = sort

    url = f"{OPENSEARCH_ENDPOINT}/{INDEX_NAME}/_search"

    try:
        r = requests.post(url, auth=awsauth, json=body, headers={"Content-Type": "application/json"}, timeout=5)
    except Exception as e:
        logger.exception("Error calling OpenSearch: %s", e)
        return {"statusCode": 502, "body": json.dumps({"error": "Search backend unavailable"}), "headers": {"Content-Type": "application/json"}}

    if r.status_code >= 300:
        logger.error("OpenSearch error %s: %s", r.status_code, r.text)
        return {"statusCode": 502, "body": json.dumps({"error": "Search query failed", "details": r.text[:500]}), "headers": {"Content-Type": "application/json"}}

    data = r.json()
    hits = data.get("hits", {}).get("hits", [])
    total = data.get("hits", {}).get("total", {}).get("value", len(hits))

    results = []
    for h in hits:
        src = h.get("_source", {})
        hl = h.get("highlight", {})

        results.append({
            "trackId": src.get("trackId"),
            "title": src.get("title"),
            "artist": src.get("artist"),
            "duration": src.get("duration"),
            "plays": src.get("plays", 0),
            "status": src.get("status"),
            "coverKey": src.get("coverKey"),
            "objectKey": src.get("objectKey") or src.get("audioS3Key"),  # tolère les 2
            "highlights": {
                "title": hl.get("title"),
                "artist": hl.get("artist")
            }
        })

    return {
        "statusCode": 200,
        "body": json.dumps({
            "q": q,
            "total": total,
            "offset": offset,
            "limit": size,
            "sort": sort_mode,
            "results": results
        }),
        "headers": {"Content-Type": "application/json"},
    }