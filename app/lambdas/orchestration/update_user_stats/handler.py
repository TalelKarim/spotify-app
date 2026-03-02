import os
import boto3
from botocore.exceptions import ClientError

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["USERS_TABLE"]
table = dynamodb.Table(TABLE_NAME)

def main(event, context):

    detail = event.get("detail", event)

    user_id = detail["userId"]
    track_id = detail["trackId"]

    pk = f"USER#{user_id}"
    sk = "METADATA"

    try:
        table.update_item(
            Key={
                "PK": pk,
                "SK": sk
            },
            UpdateExpression="""
                ADD totalPlays :inc
                SET lastPlayedTrack = :track
            """,
            ExpressionAttributeValues={
                ":inc": 1,
                ":track": track_id
            }
        )

    except ClientError as e:
        raise

    return {"status": "user_stats_updated"}