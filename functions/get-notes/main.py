# add your get-notes function here
import boto3
from boto3.dynamodb.conditions import Key
import json

def handler(event, context):
    dynamodb_resource = boto3.resource("dynamodb")
    table = dynamodb_resource.Table("lotion-30139733")

    given_email = event["queryStringParameters"]["email"]

    res = table.query(KeyConditionExpression=Key("email").eq(given_email))
    print(res["Items"])
    return {
        "statusCode": 200,
        "body": json.dumps(res["Items"])
    }