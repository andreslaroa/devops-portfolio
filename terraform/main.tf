# 1. AWS VPC
resource "aws_vpc" "portfolio_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name    = "portfolio_vpc" # El nombre que verás en la consola de AWS
    Project = "devops-portfolio"
  }
}

# 2. Public Subnet
resource "aws_subnet" "portfolio_public_subnet" {
  vpc_id                  = aws_vpc.portfolio_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # ✅ Corregido: Booleano nativo sin comillas
  
  # 🔒 CORREGIDO: Bloque "filter" eliminado. El nombre se asigna abajo en los tags.
  tags = {
    Name    = "portfolio_public_subnet"
    Project = "devops-portfolio"
  }
}

# 3. Private Subnet
resource "aws_subnet" "portfolio_private_subnet" {
  vpc_id     = aws_vpc.portfolio_vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name    = "portfolio_private_subnet"
    Project = "devops-portfolio"
  }
}

# 4. Internet Gateway
resource "aws_internet_gateway" "portfolio_internet_gateway" {
  vpc_id = aws_vpc.portfolio_vpc.id
  tags = {
    Name    = "portfolio_igw"
    Project = "devops-portfolio"
  }
}

# 5. Route Table
resource "aws_route_table" "portfolio_route_table" {
  vpc_id = aws_vpc.portfolio_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.portfolio_internet_gateway.id
  }

  tags = {
    Name = "portfolio_public_rt"
  }
}

# 6. Route Table Association (Indispensable para activar el internet en la subred)
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.portfolio_public_subnet.id
  route_table_id = aws_route_table.portfolio_route_table.id
}

# 7. Security Group
resource "aws_security_group" "portfolio_sg" {
  name        = "devops-portfolio-sg"
  description = "Allow inbound traffic for web API and SSH"
  vpc_id      = aws_vpc.portfolio_vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "FastAPI application port"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-portfolio-sg"
  }
}

#Create the SSh key on AWS
resource "aws_key_pair" "portfolio_key" {
  key_name   = "devops-portfolio-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM8IoXqhAkXQvdCMNCwmadUqFzjxr2KzNp4sUR91qLTY openbravo@por2002"  
}

# 8. EC2 Instance
resource "aws_instance" "portfolio_server" {
  ami           = "ami-0c7217cdde317cfec" # Asegúrate de que esta AMI está en tu región (us-east-1)
  instance_type = "t3.small"             # Cambiado a t2.micro para evitar cobros (Free Tier real)
  subnet_id     = aws_subnet.portfolio_public_subnet.id

  key_name = aws_key_pair.portfolio_key.key_name

  vpc_security_group_ids = [aws_security_group.portfolio_sg.id]

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