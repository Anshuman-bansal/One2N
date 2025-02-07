provider "aws" {
  region = "us-east-1"
}

# IAM Role for EC2 to Access S3
resource "aws_iam_role" "s3_access_role" {
  name = "flask_s3_access_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# IAM Policy for S3 Access
resource "aws_iam_policy" "s3_read_policy" {
  name        = "flask_s3_read_policy"
  description = "Allows EC2 to read S3 bucket content"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::one2-test"]
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject"],
      "Resource": ["arn:aws:s3:::one2-test/*"]
    }
  ]
}
EOF
}

# Attach IAM Policy to Role
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

# Instance Profile
resource "aws_iam_instance_profile" "flask_instance_profile" {
  name = "flask_instance_profile"
  role = aws_iam_role.s3_access_role.name
}

# Security Group to Allow Flask Traffic
resource "aws_security_group" "flask_sg" {
  name        = "flask_security_group"
  description = "Allow Flask (port 8000) and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH (change for security)
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow Flask API
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance for Flask App
resource "aws_instance" "flask_server" {
  ami           = "ami-085ad6ae776d8f09c"  # Amazon Linux 2023 AMI
  instance_type = "t2.micro"
  key_name      = "test"  # Replace with your key pair name

  iam_instance_profile = aws_iam_instance_profile.flask_instance_profile.name
  security_groups      = [aws_security_group.flask_sg.name]

  # Use base64 encoding for user data
  user_data = filebase64("${path.module}/user-data.sh")

  tags = {
    Name = "FlaskServer"
  }
}
