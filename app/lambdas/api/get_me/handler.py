import os
import json

ALLOWED_ORIGIN = os.environ.get("ALLOWED_ORIGIN", "http://localhost:5173")


def build_response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": ALLOWED_ORIGIN,
            "Access-Control-Allow-Credentials": "true",
        },
        "body": json.dumps(body),
    }


def main(event, context):
    # Les claims sont injectés par API Gateway
    claims = event["requestContext"]["authorizer"]["claims"]

    user_id = claims.get("sub")
    email = claims.get("email")

    return build_response(200, {
        "userId": user_id,
        "email": email
    })