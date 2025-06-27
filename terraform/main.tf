provider "aws" {
  region = "us-west-1"
   profile = "myprofile"
}

# VPC
resource "aws_vpc" "dev_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone
  tags = {
    Name        = "${var.environment}-public-subnet"
    Environment = var.environment
  }
}

# Subnet in us-west-1a
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-1a"
  tags = {
    Name        = "${var.environment}-public-subnet-a"
    Environment = var.environment
  }
}

# Subnet in us-west-1c
resource "aws_subnet" "public_subnet_c" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-1c"
  tags = {
    Name        = "${var.environment}-public-subnet-c"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    Name        = "${var.environment}-public-rt"
    Environment = var.environment
  }
}

# Route for Internet
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Route Table Association
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Route Table Association for subnet a
resource "aws_route_table_association" "public_assoc_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

# Route Table Association for subnet c
resource "aws_route_table_association" "public_assoc_c" {
  subnet_id      = aws_subnet.public_subnet_c.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group
resource "aws_security_group" "allow_all" {
  name        = "${var.environment}-allow-all"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.dev_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-allow-all"
    Environment = var.environment
  }
}

# EC2 Instances

# Jenkins Instance (large type, 25GB volume, Elastic IP, us-west-1a)
resource "aws_instance" "jenkins" {
  ami                         = var.jenkins_ami
  instance_type               = var.large_instance_type
  subnet_id                   = aws_subnet.public_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.allow_all.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  root_block_device {
    volume_size = 25
    volume_type = "gp2"
  }

  tags = {
    Name        = "${var.environment}-jenkins-instance"
    Environment = var.environment
  }
}

resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.jenkins.id
  vpc      = true
}

# SonarQube Instance (default type, Elastic IP, us-west-1a)
resource "aws_instance" "sonarqube" {
  ami                         = var.sonarqube_ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.allow_all.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name        = "${var.environment}-sonarqube-instance"
    Environment = var.environment
  }
}

resource "aws_eip" "sonarqube_eip" {
  instance = aws_instance.sonarqube.id
  vpc      = true
}

# K8s Master (large type, 25GB volume, Elastic IP, us-west-1c)
resource "aws_instance" "k8s_master" {
  ami                         = var.k8s_master_ami
  instance_type               = var.large_instance_type
  subnet_id                   = aws_subnet.public_subnet_c.id
  vpc_security_group_ids      = [aws_security_group.allow_all.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  root_block_device {
    volume_size = 25
    volume_type = "gp2"
  }

  tags = {
    Name        = "${var.environment}-k8s-master"
    Environment = var.environment
    Role        = "k8s-master"
  }
}

resource "aws_eip" "k8s_master_eip" {
  instance = aws_instance.k8s_master.id
  vpc      = true
}

# K8s Worker Nodes (default type, Elastic IP, us-west-1c)
resource "aws_instance" "k8s_worker" {
  count                       = 2
  ami                         = var.k8s_worker_ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet_c.id
  vpc_security_group_ids      = [aws_security_group.allow_all.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name        = "${var.environment}-k8s-worker-${count.index + 1}"
    Environment = var.environment
    Role        = "k8s-worker"
  }
}

resource "aws_eip" "k8s_worker_eip" {
  count    = 2
  instance = aws_instance.k8s_worker[count.index].id
  vpc      = true
}
