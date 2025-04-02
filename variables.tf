variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Amazon Machine Image (AMI) ID"
  default     = "ami-00a929b66ed6e0de6" # Amazon Linux 2 (update this for your region)
}

variable "instance_type" {
  description = "Instance type for EC2"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  default     = "terraform-key"
}

variable "inst_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1  # Change this value as needed
}
