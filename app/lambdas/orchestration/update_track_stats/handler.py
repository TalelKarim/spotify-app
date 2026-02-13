import os
import boto3
from datetime import datetime

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["TRACKS_TABLE"]
table = dynamodb.Table(TABLE_NAME)

def main(event, context):

    detail = event.get("detail", event)

    track_id = detail["trackId"]
    timestamp = detail["timestamp"]

    pk = f"TRACK#{track_id}"
    sk = "METADATA"
    
    try: 

        table.update_item(
            Key={
                "PK": pk,
                "SK": sk
            },
            UpdateExpression="""
                ADD plays :inc
                SET lastPlayedAt = :ts
            """,
            ExpressionAttributeValues={
                ":inc": 1,
                ":ts": timestamp
            },
            ConditionExpression="attribute_exists(PK)"

        )

    except ClientError as e:
        if e.response["Error"]["Code"] == "ConditionalCheckFailedException":
            raise Exception("Track does not exist")
        raise   

    return {"status": "track_stats_updated"}
