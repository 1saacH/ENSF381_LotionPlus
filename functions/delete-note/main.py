# add your delete-note function here
import boto3
import json
import base64

def handler(event, context):
    dynamodb_resource = boto3.resource("dynamodb")
    table = dynamodb_resource.Table("lotion-30139733")

    encoded_string = event["body"]
    decoded_string = base64.b64decode(encoded_string).decode()

    json_table = json.loads(decoded_string)

    given_email = json_table["email"]
    given_id = json_table["id"]
    table.delete_item(
        Key={
            "email": given_email,
            "id": given_id
        })

    return {
        "statusCode": 200,
        "body": "Note Deleted!"
    }