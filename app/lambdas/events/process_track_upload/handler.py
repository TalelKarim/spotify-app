import os
import boto3
import urllib.parse

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["TRACKS_TABLE"]
table = dynamodb.Table(TABLE_NAME)

def main(event, context):

    # S3 event structure
    record = event["Records"][0]
    bucket = record["s3"]["bucket"]["name"]
    key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])

    # key = tracks/<trackId>.mp3
    track_id = key.split("/")[-1].replace(".mp3", "")

    pk = f"TRACK#{track_id}"
    sk = "METADATA"

    table.update_item(
        Key={"PK": pk, "SK": sk},
        UpdateExpression="""
            SET #status = :ready
            REMOVE uploadExpiresAt
        """,
        ExpressionAttributeNames={
            "#status": "status"
        },
        ExpressionAttributeValues={
            ":ready": "READY"
        }
    )

    return {"status": "updated"}