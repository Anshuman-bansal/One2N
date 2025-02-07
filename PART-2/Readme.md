# Terraform configuration to deploy a Flask-based S3 listing service on AWS.


## Resources Provisioned
IAM Role & Policy: Grants S3 read access to EC2.
Security Group: Allows SSH (22) and Flask API (8000).
EC2 Instance: Runs the Flask service on Amazon Linux.


## Initialize and apply Terraform:
terraform init  
terraform apply

## Access the API at http://<EC2_PUBLIC_IP>:8000/list-bucket-content.


