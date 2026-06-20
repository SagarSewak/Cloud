provider "aws" {
  region = var.aws_region
}

# 1. Custom VPC
resource "aws_vpc" "gdb_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "gdb-vpc"
  }
}

# 2. Public Subnet for Frontend and Gateway
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.gdb_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "gdb-public-subnet"
  }
}

# 3. Private Subnet for Databases and Microservices
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.gdb_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "gdb-private-subnet"
  }
}

# 4. Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.gdb_vpc.id

  tags = {
    Name = "gdb-igw"
  }
}

# 5. Route Table for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.gdb_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "gdb-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 6. Security Group for Public Facing Services (HTTP, SSH, Gateway)
resource "aws_security_group" "public_sg" {
  name        = "gdb-public-sg"
  description = "Security Group for public services (Frontend and API Gateway)"
  vpc_id      = aws_vpc.gdb_vpc.id

  # Allow inbound HTTP for Frontend (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound HTTP for React dev/preview (port 3000)
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound Gateway traffic (port 8000)
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound SSH (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip_cidr]
  }

  # Outbound rule to allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "gdb-public-sg"
  }
}

# 7. Security Group for Internal Microservices and Database
resource "aws_security_group" "private_sg" {
  name        = "gdb-private-sg"
  description = "Security Group for internal microservices and DB"
  vpc_id      = aws_vpc.gdb_vpc.id

  # Allow SSH from public VM
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  # Allow internal communication between microservices on all internal ports (8000-8008, 8761)
  ingress {
    from_port       = 8000
    to_port         = 8761
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
    self            = true
  }

  # Allow Postgres access (port 5432) from internal microservices
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    self        = true
  }

  # Outbound rule to allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "gdb-private-sg"
  }
}

# 8. EC2 Instance for Frontend and Gateway (Public subnet)
resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = var.ssh_key_name

  vpc_security_group_ids = [aws_security_group.public_sg.id]

  tags = {
    Name = "gdb-web-server"
  }
}

# 9. EC2 Instance for Microservices and Database (Private subnet)
resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = "t3.large"
  subnet_id     = aws_subnet.private_subnet.id
  key_name      = var.ssh_key_name

  vpc_security_group_ids = [aws_security_group.private_sg.id]

  tags = {
    Name = "gdb-app-server"
  }
}
