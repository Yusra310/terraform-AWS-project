import json
import boto3
from urllib.parse import parse_qs

# Initialize DynamoDB resource
dynamodb = boto3.resource('dynamodb')
TABLE_NAME = 'datatable'

def lambda_handler(event, context):
    try:
        # Log the incoming event for debugging
        print("Event object:", json.dumps(event))

        # Ensure 'httpMethod' exists
        if 'httpMethod' not in event:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Invalid request. Missing httpMethod.'})
            }

        # Route based on HTTP method
        if event['httpMethod'] == 'GET':
            return handle_get(event)
        elif event['httpMethod'] == 'POST':
            formbody = event.get('body')
            return handle_post(formbody, event)
        else:
            return {
                'statusCode': 405,
                'body': json.dumps({'error': 'Method not allowed'})
            }
    except Exception as e:
        print(f"Error in lambda_handler: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

def handle_get(event):
    """Handles GET requests and retrieves data from DynamoDB."""
    try:
        query_params = event.get('queryStringParameters', {})
        
        if not query_params or 'email' not in query_params:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Missing required query parameter: email'})
            }
        
        email = query_params['email']
        table = dynamodb.Table(TABLE_NAME)

        response = table.get_item(Key={'email': email})
        if 'Item' in response:
            return {
                'statusCode': 200,
                'body': json.dumps({'data': response['Item']})
            }
        else:
            return {
                'statusCode': 404,
                'body': json.dumps({'error': 'Record not found'})
            }
    except Exception as e:
        print(f"Error in handle_get: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

def handle_post(formbody, event):
    """Handles POST requests, parses the form data, and inserts into DynamoDB."""
    try:
        if not formbody:
            raise ValueError("Form body is empty or not provided")

        # Check if the body is URL-encoded (common for web forms)
        if event.get('headers', {}).get('Content-Type', '') == 'application/x-www-form-urlencoded' and formbody:
            formbody = parse_qs(formbody)
            formbody = {key: value[0] for key, value in formbody.items()}

        # If the body is JSON, parse it
        elif event.get('headers', {}).get('Content-Type', '') == 'application/json' and formbody:
            formbody = json.loads(formbody)

        print(f"Parsed Form Body: {formbody}")

        # Call insert_record with the parsed body
        insert_record(formbody)

        # Serve the success page (assuming it's available)
        with open('success.html', 'r') as htmlFile:
            htmlContent = htmlFile.read()
        return {
            'statusCode': 200,
            'headers': {"Content-Type": "text/html"},
            'body': htmlContent
        }

    except Exception as e:
        print(f"Error in handle_post: {str(e)}")  # Log the error
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

def get_record_by_email(email):
    """Fetches a record from DynamoDB based on the provided email."""
    client = boto3.client('dynamodb')
    print(f"Querying DynamoDB for email: {email}")
   
    try:
        response = client.get_item(
            TableName='datatable',  # Ensure this is the correct table name
            Key={'email': {'S': email}}  # Assuming 'email' is the partition key
        )
        print(f"DynamoDB Response: {response}")
       
        if 'Item' in response:
            return {key: value['S'] for key, value in response['Item'].items()}
        else:
            return None  # No record found
    except Exception as e:
        print(f"Error querying DynamoDB: {str(e)}")
        raise ValueError(f"Error querying DynamoDB: {str(e)}")

def insert_record(parsed_body):
    """Function to insert the record into DynamoDB using PutItem."""
    if not parsed_body:
        raise ValueError("Parsed form body is empty")

    print(f"Parsed Body for DynamoDB: {parsed_body}")

    # Create a DynamoDB client
    client = boto3.client('dynamodb')

    try:
        response = client.put_item(
            TableName='datatable',  # Replace with your DynamoDB table name
            Item={key: convert_value(value) for key, value in parsed_body.items()}
        )
        print(f"Response from DynamoDB: {response}")
        return response
    except Exception as e:
        print(f"Error inserting record into DynamoDB: {str(e)}")
        raise ValueError(f"Error inserting record into DynamoDB: {str(e)}")

def convert_value(value):
    """Converts the value to a DynamoDB-compatible type."""
    if isinstance(value, str):
        return {'S': value}
    elif isinstance(value, int) or isinstance(value, float):
        return {'N': str(value)}
    elif isinstance(value, bool):
        return {'BOOL': value}
    else:
        raise ValueError(f"Unsupported data type: {type(value)}")
