variable "aws_region" {
    description = "AWS region to deploy into"
    type = string
}
variable "ami_id" {
    description = "AMI ID to use for the EC2 instance"
    type = string
}
variable "instance_type" {
    description = "EC2 instance type"
    type = string
}
variable "key_name" {
    description = "Key pair name for SSH access"
    type = string
}

variable "profile" {
    description = "Local Profile name for AWS Access"
    type = string
}

variable "my_ip" {
  description = "My public IP address for SSH access"
  type = string
}

variable "public_subnet_cidr" {
    type = string
}

variable "private_subnet_cidr" {
    type = string
}

variable "vpc_cidr" {
    type = string
}

variable "user_data" {
    type = string
}