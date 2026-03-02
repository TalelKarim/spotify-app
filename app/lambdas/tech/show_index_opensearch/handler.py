import requests
from requests_aws4auth import AWS4Auth
import boto3
import os

region = "eu-west-1"
service = "es"

credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(
    credentials.access_key,
    credentials.secret_key,
    region,
    service,
    session_token=credentials.token,
)

endpoint = os.environ["OPENSEARCH_ENDPOINT"]

def main(event, context):
    r = requests.get(f"{endpoint}/_cat/indices?v", auth=awsauth)
    return {"statusCode": 200, "body": r.text}