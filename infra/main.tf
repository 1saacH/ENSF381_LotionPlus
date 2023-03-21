terraform {
  required_providers {
    aws = {
      version = ">= 4.0.0"
      source  = "hashicorp/aws"
    }
  }
}

# specify the provider region
provider "aws" {
  region = "ca-central-1"
}

# the locals block is used to declare constants that 
# you can use throughout your code
locals {
  function_name_get = "get-notes-30140194"
  function_name_save = "save-notes-30140194"
  function_name_del = "delete-note-30140194"
  handler_name  = "main.handler"
  artifact_name_get = "../functions/get-notes/artifact.zip"
  artifact_name_save = "../functions/save-note/artifact.zip"
  artifact_name_del = "../functions/delete-note/artifact.zip"
}

# create a role for the Lambda function to assume
# every service on AWS that wants to call other AWS services should first assume a role and
# then any policy attached to the role will give permissions
# to the service so it can interact with other AWS services
# see the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "lambda-get" {
  name               = "iam-for-lambda-${local.function_name_get}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambda-save" {
  name               = "iam-for-lambda-${local.function_name_save}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambda-del" {
  name               = "iam-for-lambda-${local.function_name_del}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# create archive file from main.py
data "archive_file" "lambda-get" {
  type = "zip"
  # this file (main.py) needs to exist in the same folder as this 
  # Terraform configuration file
  source_file = "../functions/save-note/main.py"
  output_path = "../functions/save-note/artifact.zip"
}

data "archive_file" "lambda-save" {
  type = "zip"
  # this file (main.py) needs to exist in the same folder as this 
  # Terraform configuration file
  source_file = "../functions/get-notes/main.py"
  output_path = "../functions/get-notes/artifact.zip"
}

data "archive_file" "lambda-del" {
  type = "zip"
  # this file (main.py) needs to exist in the same folder as this 
  # Terraform configuration file
  source_file = "../functions/delete-note/main.py"
  output_path = "../functions/delete-note/artifact.zip"
}

# create a Lambda function
# see the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
resource "aws_lambda_function" "lambda-get" {
  role             = aws_iam_role.lambda-get.arn
  function_name    = local.function_name_get
  handler          = local.handler_name
  filename         = local.artifact_name_get
  source_code_hash = data.archive_file.lambda-get.output_base64sha256

  # see all available runtimes here: https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime
  runtime = "python3.9"
}

resource "aws_lambda_function" "lambda-save" {
  role             = aws_iam_role.lambda-save.arn
  function_name    = local.function_name_save
  handler          = local.handler_name
  filename         = local.artifact_name_save
  source_code_hash = data.archive_file.lambda-save.output_base64sha256

  # see all available runtimes here: https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime
  runtime = "python3.9"
}

resource "aws_lambda_function" "lambda-del" {
  role             = aws_iam_role.lambda-del.arn
  function_name    = local.function_name_del
  handler          = local.handler_name
  filename         = local.artifact_name_del
  source_code_hash = data.archive_file.lambda-del.output_base64sha256

  # see all available runtimes here: https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime
  runtime = "python3.9"
}

resource "aws_dynamodb_table" "lotion-30139733" {
  name = "lotion-30139733"
  billing_mode = "PROVISIONED"

  read_capacity = 1
  write_capacity = 1

  hash_key = "email"
  range_key = "id"

  attribute {
    name = "email"
    type = "S"
  }
  attribute {
    name = "id"
    type = "N"
  }
}

# create a policy for publishing logs to CloudWatch
# see the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "logs-get" {
  name        = "lambda-logging-${local.function_name_get}"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "logs-save" {
  name        = "lambda-logging-${local.function_name_save}"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "logs-del" {
  name        = "lambda-logging-${local.function_name_del}"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# attach the above policy to the function role
# see the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "lambda_logs-get" {
  role       = aws_iam_role.lambda-get.name
  policy_arn = aws_iam_policy.logs-get.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logs-save" {
  role       = aws_iam_role.lambda-save.name
  policy_arn = aws_iam_policy.logs-save.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logs-del" {
  role       = aws_iam_role.lambda-del.name
  policy_arn = aws_iam_policy.logs-del.arn
}

# create a Function URL for Lambda 
# see the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_url
resource "aws_lambda_function_url" "url-get" {
  function_name      = aws_lambda_function.lambda-get.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["GET"]
    allow_headers     = ["*"]
    expose_headers    = ["keep-alive", "date"]
  }
}

resource "aws_lambda_function_url" "url-save" {
  function_name      = aws_lambda_function.lambda-save.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["POST", "PUT"]
    allow_headers     = ["*"]
    expose_headers    = ["keep-alive", "date"]
  }
}

resource "aws_lambda_function_url" "url-del" {
  function_name      = aws_lambda_function.lambda-del.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["DELETE"]
    allow_headers     = ["*"]
    expose_headers    = ["keep-alive", "date"]
  }
}

# show the Function URL after creation
output "lambda_url-get" {
  value = aws_lambda_function_url.url-get.function_url
}

output "lambda_url-save" {
  value = aws_lambda_function_url.url-save.function_url
}

output "lambda_url-del" {
  value = aws_lambda_function_url.url-del.function_url
}