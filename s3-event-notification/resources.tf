terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0,!= 3.14.0"
    }
  }
}

// Update AWS user profile and region as you want
provider "aws" {
  profile = "A4L-MASTER"
  region = "us-east-1"
}

// Update the name as you want for bucket a, bucket b
locals {
  bucket_a_name = "event1-trigger-test-bucket-a"
  bucket_b_name = "event2-trigger-test-bucket-b"
}

resource "aws_iam_role" "iam_for_s3_event_trigger_lambda" {
  name = "iam_for_s3_event_trigger_lambda"
  managed_policy_arns = [aws_iam_policy.bucket_a.arn, aws_iam_policy.bucket_b.arn]

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "bucket_a" {
  name = "policy-bucket_a-read_access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject"]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${local.bucket_a_name}/*"
      },
    ]
  })
}

resource "aws_iam_policy" "bucket_b" {
  name = "policy-bucket_b-write_access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:putObject"]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${local.bucket_b_name}/*"
      },
    ]
  })
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id = "AllowExecutionFromS3Bucket"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func.arn
  principal = "s3.amazonaws.com"
  source_arn = aws_s3_bucket.bucket_a.arn
}

resource "aws_lambda_function" "func" {
  filename = "lambda/s3_event_trigger_lambda.zip"
  function_name = "s3_event_trigger_lambda"
  role = aws_iam_role.iam_for_s3_event_trigger_lambda.arn
  handler = "s3_event_trigger_lambda.lambda_handler"
  runtime = "python3.8"
}

resource "aws_s3_bucket" "bucket_a" {
  bucket = local.bucket_a_name
}

resource "aws_s3_bucket" "bucket_b" {
  bucket = local.bucket_b_name
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket_a.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.func.arn
    events = [
      "s3:ObjectCreated:*"]
    filter_suffix = ".jpg"
  }

  depends_on = [
    aws_lambda_permission.allow_bucket]
}

////////// User roles //////////////

// User A
resource "aws_iam_user" "user_a" {
  name = "user_a"
}

resource "aws_iam_user_policy" "policy_user_a" {
  name = "policy_user_a"
  user = aws_iam_user.user_a.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:putObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.bucket_a_name}/*"
    }
  ]
}
EOF
}

// User B
resource "aws_iam_user" "user_b" {
  name = "user_b"
}

resource "aws_iam_user_policy" "policy_user_b" {
  name = "policy_user_b"
  user = aws_iam_user.user_b.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.bucket_b_name}/*"
    }
  ]
}
EOF
}

