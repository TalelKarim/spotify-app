import os
import boto3

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["USERS_TABLE"]
table = dynamodb.Table(TABLE_NAME)

def main(event, context):

    detail = event.get("detail", event)

    user_id = detail["userId"]
    track_id = detail["trackId"]

    pk = f"USER#{user_id}"
    sk = "METADATA"

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

    return {"status": "user_stats_updated"}
