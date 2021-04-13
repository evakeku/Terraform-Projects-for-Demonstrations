1. Browse the resources.tf terraform file

2. Please update the following value in that file

// Update AWS user profile and region as you want
provider "aws" {
  profile = "A4-MASTER"
  region = "us-east-1"
}

// Update the name as you want for bucket a, bucket b
locals {
  bucket_a_name = "event1-trigger-test-bucket-a"
  bucket_b_name = "event2-trigger-test-bucket-b"
}

4. Then browse the lambda python file  "s3_event_trigger_lambda.py" and update the bucket_b_name as you configured in the 2nd step.

  # Note: Update the bucket b name to your bucket b name
    bucket_b = 'event2-trigger-test-bucket-b'

5. Zip the python file as "s3_event_trigger_lambda.zip" and save in the same directory

3. Then run "terraform init" command.

4. After that run "terraform plan" and check all the resource and then run "terraform apply". Type "yes" for the confirmation.

5.Then upload a file to bucket a and test.
