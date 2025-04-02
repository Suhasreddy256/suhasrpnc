output "ec2_public_ip" {
  value = aws_instance.my_amazon_ec2[*].public_ip  # ✅ Fixed Name
}

output "ec2_private_ip" {
  value = aws_instance.my_amazon_ec2[*].private_ip  # ✅ Fixed Name
}
