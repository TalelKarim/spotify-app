# api_healthcheck.py

import json
import os


def main(event, context):
    body = {
        "status": "ok",
        "service": os.environ.get("SERVICE_NAME", "spotify-api"),
        "version": os.environ.get("VERSION", "v1"),
    }

    return {
        "statusCode": 200,
        "body": json.dumps(body),
        "headers": {"Content-Type": "application/json"},
    }
