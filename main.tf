provider "aws" {
  region = var.aws_region
}

# Generate SSH Key Pair
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "local_file" "private_key" {
  filename = "${aws_key_pair.deployer.key_name}.pem"
  content  = tls_private_key.ec2_key.private_key_pem

  provisioner "local-exec" {
    command = "chmod 600 ${self.filename}"
  }
}

# Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Terraform-VPC"
  }
}

# Create a Public Subnet
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Terraform-Public-Subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Terraform-IGW"
  }
}

# Create a Route Table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Terraform-RouteTable"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "route_assoc" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.route_table.id
}

# Create Security Group
resource "aws_security_group" "ssh_http" {
  vpc_id = aws_vpc.main_vpc.id
  name   = "allow_ssh_http"

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform-SG"
  }
}

# Create EC2 Instance
resource "aws_instance" "my_amazon_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  subnet_id              = aws_subnet.public1.id  # ✅ Fixed: Declared subnet
  vpc_security_group_ids = [aws_security_group.ssh_http.id]  # ✅ Fixed: Declared security group
  associate_public_ip_address = true
  count                  = var.inst_count  # ✅ Fixed: Declared in variables.tf

  tags = {
    Name = "Terraform-EC2"
  }
}
