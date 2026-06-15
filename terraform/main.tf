# Security Group: This acts as a virtual firewall for our server
resource "aws_security_group" "portfolio_sg" {
  name        = "devops-portfolio-sg"
  description = "Allow inbound traffic for web API and SSH"

  # SSH Access (Port 22) to securely connect to the machine
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In production, restrict this to your IP
  }

  # FastAPI Web Traffic (Port 8000)
  ingress {
    description = "FastAPI application port"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allows anyone to query the API online
  }

  # Outbound Rules: Allow the server to download packages from the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-portfolio-sg"
  }
}

# EC2 Instance: Our virtual server in the cloud
resource "aws_instance" "portfolio_server" {
  ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS AMI ID for us-east-1
  instance_type = "t3.small"             # 100% Free Tier eligible

  # Attach the firewall we defined above
  vpc_security_group_ids = [aws_security_group.portfolio_sg.id]

  # User Data: A startup script that runs automatically when the machine is born
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io docker-compose
              systemctl start docker
              systemctl enable docker
              EOF

  tags = {
    Name = "devops-portfolio-server"
  }
}
