# add your delete-note function here
import boto3

def handler(event, context):
    dynamodb_resource = boto3.resource("dynamodb")
    table = dynamodb_resource.Table("lotion-30139733")

    given_email = event["body"]["email"]
    given_id = event["body"]["id"]
    table.delete_item(
        Key={
            "email": given_email,
            "id": given_id
        })

    return {
        "statusCode": 200,
        "body": "Note Deleted!"
    }