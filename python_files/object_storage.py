# source: https://medium.com/@tatianatylosky/uploading-files-with-python-using-digital-ocean-spaces-58c9a57eb05b
from boto3 import session
from botocore.client import Config

# grab ACCESS_ID and SECRET_KEY from environment variables
ACCESS_ID = 'Changeme'
SECRET_KEY = 'Changeme'

# Initiate session
session = session.Session()
client = session.client('s3',
                        region_name = 'nyc3',
                        endpoint_url = 'https://nyc3.digitaloceanspaces.com',
                        aws_access_key_id = ACCESS_ID,
                        aws_secret_access_key=SECRET_KEY)

