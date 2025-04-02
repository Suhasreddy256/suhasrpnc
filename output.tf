output "ec2_public_ip" {
  description = "Public IP of the created EC2 instance"
  value       = aws_instance.ec2_instance.public_ip
}

output "ec2_private_ip" {
  description = "Private IP of the created EC2 instance"
  value       = aws_instance.ec2_instance.private_ip
}
