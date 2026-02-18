import json

def main(event, context):

    # Les claims sont injectés par API Gateway
    claims = event["requestContext"]["authorizer"]["claims"]

    user_id = claims.get("sub")
    email = claims.get("email")

    return {
        "statusCode": 200,
        "body": json.dumps({
            "userId": user_id,
            "email": email
        })
    }

