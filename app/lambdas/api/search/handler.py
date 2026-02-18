import os
import json
import boto3
from decimal import Decimal
from boto3.dynamodb.conditions import Attr

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


def clean_item(item):
    # On enlève les clés techniques du single-table design
    cleaned = {k: v for k, v in item.items() if k not in ("PK", "SK")}
    return decimal_to_native(cleaned)


def main(event, context):
    # Récupérer les query string params
    params = event.get("queryStringParameters") or {}

    q = params.get("q") if params else None
    if not q:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing required query parameter 'q'"}),
            "headers": {
                "Content-Type": "application/json",
            },
        }

    # limit optionnel
    try:
        limit = int(params.get("limit", 20))
    except (TypeError, ValueError):
        limit = 20

    # On fait un scan avec un FilterExpression sur title ou artist
    # Attention: c'est case-sensitive et pas optimisé, mais ok pour un lab
    filter_expr = Attr("title").contains(q) | Attr("artist").contains(q)

    try:
        response = table.scan(
            FilterExpression=filter_expr,
            Limit=limit,
        )
    except Exception as e:
        # Log minimal si besoin
        print(f"Error scanning table {TABLE_NAME}: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Internal error while searching"}),
            "headers": {
                "Content-Type": "application/json",
            },
        }

    items = response.get("Items", [])
    cleaned_items = [clean_item(it) for it in items]

    body = {
        "query": q,
        "count": len(cleaned_items),
        "items": cleaned_items,
    }

    return {
        "statusCode": 200,
        "body": json.dumps(body),
        "headers": {
            "Content-Type": "application/json",
        },
    }
