# Install Minikube on Amazon linux with docker daemon
resource "aws_instance" "my_amazon_ec2" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.public1.id
  key_name        = var.key_name
  security_groups = [aws_security_group.ssh_http.id]
  user_data       = file("./data/amazon.sh")
  root_block_device { volume_size = var.ebs_volume_size }
  tags            = merge(var.tags, { Name = "my_amazon_ec2" })
  count           = var.inst_count
}

resource "null_resource" "amazon_transfer" {
  for_each = {
    file1 = "./data/bus_app.zip"
  }

  provisioner "file" {
    source      = each.value
    destination = "/home/ec2-user/${basename(each.value)}"

    connection {
      type        = "ssh"
      host        = aws_instance.my_amazon_ec2[0].public_ip
      user        = "ec2-user"
      private_key = file(local_file.ec2-vpc.filename)
    }
  }

  depends_on = [aws_instance.my_amazon_ec2]
}

output "public_ip_amazon" {
  value = aws_instance.my_amazon_ec2[*].public_ip
}
