variable "my_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "ec2-vpc-key"
}

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default = {
    Environment = "Dev"
    Owner       = "Admin"
  }
}
