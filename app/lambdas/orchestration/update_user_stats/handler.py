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
            },
            ConditionExpression="attribute_exists(PK)"

        )

    except ClientError as e:
        if e.response["Error"]["Code"] == "ConditionalCheckFailedException":
            raise Exception("User does not exist")
        raise    
    return {"status": "user_stats_updated"}
