import os
import json
from logger import StructuredLogger

import boto3
import requests
from requests_aws4auth import AWS4Auth

logger = StructuredLogger(__name__)

region = os.environ.get("AWS_REGION", "eu-west-1")
service = "es"
ALLOWED_ORIGIN = os.environ.get("ALLOWED_ORIGIN", "http://localhost:5173")

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

    params = event.get("queryStringParameters") or {}

    q = (params.get("q") or "").strip()
    if not q:
        logger.warning("Missing search query")
        return build_response(400, {"error": "Missing query parameter 'q'"})

    logger.info("Executing track search", query=q)

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
        r = requests.post(url, auth=awsauth, json=body, headers={"Content-Type": "application/json"}, timeout=10)
    except Exception as e:
        logger.exception("Error calling OpenSearch", error=str(e))
        return build_response(502, {"error": "Search backend unavailable"})

    if r.status_code >= 300:
        logger.error("OpenSearch returned an error", statusCode=r.status_code, responseBody=r.text[:500])
        return build_response(502, {"error": "Search query failed", "details": r.text[:500]})

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

    logger.info("Track search completed", resultCount=len(results), total=total, sort=sort_mode)

    return build_response(200, {
        "q": q,
        "total": total,
        "offset": offset,
        "limit": size,
        "sort": sort_mode,
        "results": results
    })