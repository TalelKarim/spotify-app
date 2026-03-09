# api_healthcheck.py

import json
import os

ALLOWED_ORIGIN = os.environ.get("ALLOWED_ORIGIN", "http://localhost:5173")


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
    body = {
        "status": "ok",
        "service": os.environ.get("SERVICE_NAME", "spotify-api"),
        "version": os.environ.get("VERSION", "v1"),
    }

    return build_response(200, body)