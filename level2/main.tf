provider "aws" {
  region  = var.aws_region
  profile = var.profile
}

#VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

#Public Subnet (Webserver)
resource "aws_subnet" "public_subnet" {
  cidr_block              = var.public_subnet_cidr
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
}

#Private Subnet A (RDS)
resource "aws_subnet" "private_subnet" {
  cidr_block        = var.private_subnet_cidr
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.aws_region}a"
}

#Private Subnet B (RDS Multi-AZ)
resource "aws_subnet" "private_subnet_2" {
  cidr_block        = var.private_subnet_2_cidr
  vpc_id            = aws_vpc.main.id
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

#Security Group Webserver
resource "aws_security_group" "web_sg" {
  name   = "webserver-sg"
  vpc_id = aws_vpc.main.id

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

# Security Group RDS
resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description     = "MySQL from EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "wordpress-db-subnets"
  subnet_ids = [
    aws_subnet.private_subnet.id,
    aws_subnet.private_subnet_2.id
  ]
}

# RDS Multi-AZ Instance
resource "aws_db_instance" "wordpress_db" {
  identifier        = "wordpress-db"
  engine            = "mariadb"
  engine_version    = "10.6"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "wordpress"
  username = var.db_user
  password = var.db_password

  multi_az            = true
  publicly_accessible = false
  storage_encrypted   = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
}

#EC2 Instance
resource "aws_instance" "ec2instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data = templatefile("${path.module}/userdata.sh", {
    db_host = aws_db_instance.wordpress_db.address
    db_user = var.db_user
    db_pass = var.db_password
  })

  tags = {
    Name = "wordpress-webserver"
  }
}