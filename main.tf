
provider "aws" {
  region     = var.my_region
  #profile = "kloudtom"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name # Create "ec2-vpc key" in AWS!!
  public_key = tls_private_key.private_key.public_key_openssh

}

resource "local_file" "ec2-vpc" {
  filename = "${aws_key_pair.key_pair.key_name}.pem"
  content  = tls_private_key.private_key.private_key_pem

  provisioner "local-exec" {
    command = "chmod 600 ${self.filename}"
  }
}

# Create security group allowing SSH
resource "aws_security_group" "ssh_http" {
  name        = "allow-ssh-http"
  description = "Allow SSH and Http inbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 8080
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
