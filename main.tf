provider "aws" {
  region = var.my_region
}

# Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# Generate a new RSA private key
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create an AWS key pair using the generated private key
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.private_key.public_key_openssh
}

# Save the private key locally
resource "local_file" "ec2-vpc" {
  filename = "${aws_key_pair.key_pair.key_name}.pem"
  content  = tls_private_key.private_key.private_key_pem

  provisioner "local-exec" {
    command = "chmod 600 ${self.filename}"
  }
}

# Create security group allowing SSH & HTTP
resource "aws_security_group" "ssh_http" {
  name        = "allow-ssh-http"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, { Name = "vpc-ec2-sg-grp-tf-1" })
}
