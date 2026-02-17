# api_get_my_history.py

import os
import json
from decimal import Decimal

import boto3

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["LISTENING_EVENTS_TABLE"]
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


def extract_user_id(event):
    """
    Supporte :
    - REST API Gateway + Cognito User Pools -> event.requestContext.authorizer.claims
    - HTTP API + JWT authorizer -> event.requestContext.authorizer.jwt.claims
    """
    rc = event.get("requestContext", {}) or {}

    # REST API
    auth = rc.get("authorizer", {})
    claims = auth.get("claims")
    if claims:
        return claims.get("sub") or claims.get("cognito:username")

    # HTTP API
    jwt = auth.get("jwt")
    if jwt and "claims" in jwt:
        c = jwt["claims"]
        return c.get("sub") or c.get("cognito:username")

    return None


def main(event, context):
    user_id = extract_user_id(event)
    if not user_id:
        return {
            "statusCode": 401,
            "body": json.dumps({"error": "Unauthorized"}),
        }

    params = event.get("queryStringParameters") or {}
    limit = params.get("limit")
    try:
        limit = int(limit) if limit else 50
    except ValueError:
        limit = 50

    pk = f"USER#{user_id}"

    resp = table.query(
        KeyConditionExpression="PK = :pk",
        ExpressionAttributeValues={":pk": pk},
        ScanIndexForward=False,  # plus récents d'abord
        Limit=limit,
    )

    items = [decimal_to_native(item) for item in resp.get("Items", [])]

    body = {
        "userId": user_id,
        "items": items,
    }

    return {
        "statusCode": 200,
        "body": json.dumps(body),
        "headers": {"Content-Type": "application/json"},
    }
