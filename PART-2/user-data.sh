#!/bin/bash

# Update system and install dependencies
sudo yum update -y
sudo yum install -y python3 git
python3 -m ensurepip
pip3 install --upgrade pip
pip3 install flask boto3

# Set environment variables
echo "export BUCKET_NAME='one2-test'" | sudo tee -a /etc/environment
echo "export AWS_REGION='us-east-1'" | sudo tee -a /etc/environment
source /etc/environment

# Move to home directory
cd /home/ec2-user

# Create Flask application
cat <<EOF > app.py
from flask import Flask, jsonify
import boto3
import os

app = Flask(__name__)

AWS_REGION = os.getenv('AWS_REGION', 'us-east-1')
BUCKET_NAME = os.getenv('BUCKET_NAME', 'one2-test')

s3_client = boto3.client('s3', region_name=AWS_REGION)

@app.route('/list-bucket-content', defaults={'path': ''})
@app.route('/list-bucket-content/<path:path>')
def list_s3_content(path):
    try:
        prefix = f'{path}/' if path else ''
        response = s3_client.list_objects_v2(Bucket=BUCKET_NAME, Prefix=prefix, Delimiter='/')

        contents = []
        if 'CommonPrefixes' in response:
            contents.extend([obj['Prefix'].rstrip('/').split('/')[-1] for obj in response['CommonPrefixes']])
        if 'Contents' in response:
            contents.extend([obj['Key'].split('/')[-1] for obj in response['Contents'] if obj['Key'] != prefix])

        return jsonify({'content': contents})
    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
EOF

# Open firewall for Flask
sudo firewall-cmd --add-port=8000/tcp --permanent
sudo firewall-cmd --reload

# Start Flask app
nohup python3 app.py > flask.log 2>&1 &
