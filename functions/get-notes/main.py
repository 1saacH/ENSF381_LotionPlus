# add your get-notes function here
import boto3
import json

def handler(event, context):
    dynamodb_resource = boto3.resource("dynamodb")
    table = dynamodb_resource.Table("lotion-30139733")

    given_email = event["body"]["email"]

    response = table.get_item(Key={"email": given_email})

    return {
        "statusCode": 200,
        "body": json.dumps({
            "notes": response
        })
    }