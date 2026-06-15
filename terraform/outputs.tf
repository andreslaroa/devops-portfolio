# Output the public IP address of the EC2 instance
output "server_public_ip" {
  description = "The public IP address of our cloud server"
  value       = aws_instance.portfolio_server.public_ip
}
