import requests
from requests_aws4auth import AWS4Auth
import boto3
import os
from logger import StructuredLogger

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
logger = StructuredLogger(__name__)

if not endpoint.startswith("http"):
    endpoint = f"https://{endpoint}"
    
def main(event, context):
    logger.clear_context()
    logger.set_lambda_context(context)
    logger.info("Listing OpenSearch indices", endpoint=endpoint)

    r = requests.get(f"{endpoint}/_cat/indices?v", auth=awsauth)
    logger.info("Listed OpenSearch indices", statusCode=r.status_code)
    return {"statusCode": 200, "body": r.text}