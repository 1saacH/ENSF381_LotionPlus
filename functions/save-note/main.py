# add your save-note function here
import boto3

def handler(event, context):
    dynamodb_resource = boto3.resource("dynamodb")
    table = dynamodb_resource.Table("lotion-30139733")

    given_email = event["body"]["email"]
    given_id = event["body"]["id"]
    given_content = event["body"]["content"]

    data = table.put_item(
        Item={
            "email": {
                "S": given_email
            },
            "id": {
                "N": given_id
            },
            "content": {
                "S": given_content
            }
        }
    )

    return {
        "statusCode": 200,
        "body": "successfully created item!"
    }