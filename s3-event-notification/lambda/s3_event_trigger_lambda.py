import json
import urllib.parse
import boto3

s3 = boto3.client('s3')


def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))

    # Note: Update the bucket b name to your bucket b name
    bucket_b = 'event2-trigger-test-bucket-b'

    # Get the object from the event and show its content type
    bucket_a = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    try:
        s3.copy_object(CopySource={'Bucket': bucket_a, 'Key': key}, Bucket=bucket_b, Key=key, Metadata={}, MetadataDirective='REPLACE')
        print('Successfully copied object {} from bucket {}. to bucket {}'.format(key, bucket_a, bucket_b))
    except Exception as e:
        print('Error copying object {} from bucket {}. to bucket {}'.format(key, bucket_a, bucket_b))
        print(e)
        raise e
