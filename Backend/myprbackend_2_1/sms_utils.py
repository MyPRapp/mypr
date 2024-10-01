import boto3

def send_sms(phone_number, message):
    # Replace with your AWS credentials and region
    session = boto3.Session(
        aws_access_key_id='YOUR_AWS_ACCESS_KEY_ID',
        aws_secret_access_key='YOUR_AWS_SECRET_ACCESS_KEY',
        region_name='YOUR_AWS_REGION'
    )
    pinpoint = session.client('pinpoint')

    # Replace with your Amazon Pinpoint project ID and origination number
    project_id = 'YOUR_PINPOINT_PROJECT_ID'
    origination_number = 'YOUR_ORIGINATION_NUMBER'

    try:
        response = pinpoint.send_messages(
            ApplicationId=project_id,
            MessageRequest={
                'Addresses': {
                    phone_number: {
                        'ChannelType': 'SMS'
                    }
                },
                'MessageConfiguration': {
                    'SMSMessage': {
                        'Body': message,
                        'MessageType': 'TRANSACTIONAL',
                        'OriginationNumber': origination_number
                    }
                }
            }
        )
        print(f"Message sent! Message ID: {response['MessageResponse']['Result'][phone_number]['MessageId']}")
    except Exception as e:
        print(f"Error sending SMS: {e}")
