provider "aws" {
    region = var.aws_region
    profile = var.profile
}

#VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

#Public Subnet
resource "aws_subnet" "public_subnet" {
  cidr_block              = var.public_subnet_cidr
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
}

#Private Subnet
resource "aws_subnet" "private_subnet" {
  cidr_block = var.private_subnet_cidr
  vpc_id     = aws_vpc.main.id
  availability_zone = "${var.aws_region}b"
}

#Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

#Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

#Route Table Association
resource "aws_route_table_association" "pub_assoc" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet.id
}

#Security Group
resource "aws_security_group" "web_sg" {
  name        = "webserver-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH only from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#EC2 Instance
resource "aws_instance" "example" {
    ami = var.ami_id
    instance_type = var.instance_type
    key_name = var.key_name
    subnet_id = aws_subnet.public_subnet.id
    vpc_security_group_ids = [aws_security_group.web_sg.id]
    user_data = file("${path.module}/${var.user_data}")

    tags = {
        Name = "wordpress-webserver"
    }
}