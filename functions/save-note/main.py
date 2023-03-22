# add your save-note function here
import boto3
import json

def handler(event, context):
    dynamodb_resource = boto3.resource("dynamodb")
    table = dynamodb_resource.Table("lotion-30139733")

    encoded_string = event["body"]

    json_table = json.loads(encoded_string)

    given_email = json_table["email"]
    given_id = json_table["id"]
    given_note = json_table["note"]

    item = {
        "email": given_email,
        "id": str(given_id),
        "title": given_note["title"],
        "content": given_note["body"],
        "date": given_note["when"]
    }

    try:
        table.put_item(Item=item)
    except Exception as exp:
        print(exp)

    return {
        "statusCode": 200,
        "body": "successfully created item!"
    }