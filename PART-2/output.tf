output "ec2_public_ip" {
  value       = aws_instance.flask_server.public_ip
  description = "Public IP of the Flask server"
}
