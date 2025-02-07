## S3 Bucket Content Listing Service
A simple Flask-based API to list contents of an S3 bucket.

## API Endpoint
GET /list-bucket-content/<path>

Lists directories and files in the given S3 path.
If no path is provided, it returns the top-level contents.

## Setup

pip install flask boto3

## Run the service:
python app.py
