import os
import json
import time
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

# Reuse HTTP connection pool across warm invocations
http_session = requests.Session()


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


def now_ms() -> float:
    return time.perf_counter() * 1000


def elapsed_ms(start_ms: float) -> float:
    return round(now_ms() - start_ms, 2)


def main(event, context):
    request_start_ms = now_ms()

    logger.clear_context()
    logger.set_lambda_context(context)

    params = event.get("queryStringParameters") or {}

    q = (params.get("q") or "").strip()
    if not q:
        logger.warning(
            "Missing search query",
            totalDurationMs=elapsed_ms(request_start_ms),
        )
        return build_response(400, {"error": "Missing query parameter 'q'"})

    logger.info("Executing track search", query=q)

    # pagination
    pagination_start_ms = now_ms()
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

    pagination_duration_ms = elapsed_ms(pagination_start_ms)

    # sorting
    sorting_start_ms = now_ms()
    sort_mode = (params.get("sort") or "relevance").lower()
    if sort_mode == "popular":
        sort = [{"plays": "desc"}, {"_score": "desc"}]
    elif sort_mode == "new":
        sort = [{"createdAt": "desc"}, {"_score": "desc"}]
    else:
        sort = None  # relevance default

    sorting_duration_ms = elapsed_ms(sorting_start_ms)

    # query build
    query_build_start_ms = now_ms()
    body = {
        "from": offset,
        "size": size,
        "query": {
            "bool": {
                "filter": [
                    {"term": {"status.keyword": "READY"}}
                ],
                "should": [
                    {"match_phrase": {"title": {"query": q, "boost": 4}}},
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
    query_build_duration_ms = elapsed_ms(query_build_start_ms)

    logger.info(
        "Search request prepared",
        query=q,
        limit=size,
        offset=offset,
        sort=sort_mode,
        paginationDurationMs=pagination_duration_ms,
        sortingDurationMs=sorting_duration_ms,
        queryBuildDurationMs=query_build_duration_ms,
        preparationDurationMs=elapsed_ms(request_start_ms),
    )

    # OpenSearch call
    opensearch_call_start_ms = now_ms()
    try:
        r = http_session.post(
            url,
            auth=awsauth,
            json=body,
            headers={"Content-Type": "application/json"},
            timeout=10,
        )
    except Exception as e:
        logger.exception(
            "Error calling OpenSearch",
            query=q,
            error=str(e),
            opensearchCallDurationMs=elapsed_ms(opensearch_call_start_ms),
            totalDurationMs=elapsed_ms(request_start_ms),
        )
        return build_response(502, {"error": "Search backend unavailable"})

    opensearch_call_duration_ms = elapsed_ms(opensearch_call_start_ms)

    logger.info(
        "OpenSearch HTTP call completed",
        query=q,
        statusCode=r.status_code,
        opensearchCallDurationMs=opensearch_call_duration_ms,
        responseSizeBytes=len(r.text.encode("utf-8")),
    )

    if r.status_code >= 300:
        logger.error(
            "OpenSearch returned an error",
            query=q,
            statusCode=r.status_code,
            responseBody=r.text[:500],
            opensearchCallDurationMs=opensearch_call_duration_ms,
            totalDurationMs=elapsed_ms(request_start_ms),
        )
        return build_response(502, {"error": "Search query failed", "details": r.text[:500]})

    # JSON parse
    json_parse_start_ms = now_ms()
    data = r.json()
    json_parse_duration_ms = elapsed_ms(json_parse_start_ms)

    # Result extraction / transformation
    transform_start_ms = now_ms()
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
            "objectKey": src.get("objectKey") or src.get("audioS3Key"),
            "highlights": {
                "title": hl.get("title"),
                "artist": hl.get("artist")
            }
        })

    transform_duration_ms = elapsed_ms(transform_start_ms)

    total_duration_ms = elapsed_ms(request_start_ms)

    logger.info(
        "Track search completed",
        query=q,
        resultCount=len(results),
        total=total,
        sort=sort_mode,
        opensearchCallDurationMs=opensearch_call_duration_ms,
        jsonParseDurationMs=json_parse_duration_ms,
        transformDurationMs=transform_duration_ms,
        totalDurationMs=total_duration_ms,
    )

    return build_response(200, {
        "q": q,
        "total": total,
        "offset": offset,
        "limit": size,
        "sort": sort_mode,
        "results": results
    })