# api_healthcheck.py

import json
import os
from logger import StructuredLogger

ALLOWED_ORIGIN = os.environ.get("ALLOWED_ORIGIN", "http://localhost:5173")
logger = StructuredLogger(__name__)


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
    logger.info("Healthcheck requested")

    body = {
        "status": "ok",
        "service": os.environ.get("SERVICE_NAME", "spotify-api"),
        "version": os.environ.get("VERSION", "v1"),
    }

    logger.info("Healthcheck completed", status=body["status"])
    return build_response(200, body)